{ config, lib, pkgs, ... }:

let
  cfg = config.phil.server.services.calibre;

  inherit (lib) concatStringsSep mkEnableOption mkIf mkOption optional optionalString types;
in
{
  options = {
    phil.server.services.calibre = {
      enable = mkEnableOption "Calibre-Web";

      listen = {
        ip = mkOption {
          type = types.str;
          default = "::1";
          description = ''
            IP address that Calibre-Web should listen on.
          '';
        };

        port = mkOption {
          type = types.port;
          default = 8083;
          description = ''
            Listen port for Calibre-Web.
          '';
        };

        host = mkOption {
          type = types.str;
          default = "calibre";
        };
      };

      dataDir = mkOption {
        type = types.str;
        default = "calibre-web";
        description = ''
          The directory below <filename>/var/lib</filename> where Calibre-Web stores its data.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "nixos";
        description = "User account under which Calibre-Web runs.";
      };

      options = {
        calibreLibrary = mkOption {
          type = types.nullOr types.str;
          default = "/media/syncthing/data/calibre_folder";
          description = ''
            Path to Calibre library.
          '';
        };

        enableBookConversion = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Configure path to the Calibre's ebook-convert in the DB.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.calibre-web =
      let
        appDb = "/var/lib/${cfg.dataDir}/app.db";
        gdriveDb = "/var/lib/${cfg.dataDir}/gdrive.db";
        calibreWebCmd = "${pkgs.calibre-web}/bin/calibre-web -p ${appDb} -g ${gdriveDb}";

        settings = concatStringsSep ", " ([
          "config_port = ${toString cfg.listen.port}"
          "config_uploading = 1"
        ] ++ optional (cfg.options.calibreLibrary != null) "config_calibre_dir = '${cfg.options.calibreLibrary}'"
        ++ optional cfg.options.enableBookConversion "config_converterpath = '${pkgs.calibre}/bin/ebook-convert'");
      in
      {
        description = "Web app for browsing, reading and downloading eBooks stored in a Calibre database";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          User = cfg.user;
          Group = "users";

          StateDirectory = cfg.dataDir;
          ExecStartPre = pkgs.writeShellScript "calibre-web-pre-start" (
            ''
              __RUN_MIGRATIONS_AND_EXIT=1 ${calibreWebCmd}
              ${pkgs.sqlite}/bin/sqlite3 ${appDb} "update settings set ${settings}"
            '' + optionalString (cfg.options.calibreLibrary != null) ''
              test -f ${cfg.options.calibreLibrary}/metadata.db || { echo "Invalid Calibre library"; exit 1; }
            ''
          );

          ExecStart = "${calibreWebCmd} -i ${cfg.listen.ip}";
          Restart = "on-failure";
        };
      };

    phil.server.services.caddy.proxy."${cfg.listen.host}" = { inherit (cfg.listen) port; };
  };
}
