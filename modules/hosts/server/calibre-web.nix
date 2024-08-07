{
  config,
  lib,
  netlib,
  ...
}: let
  cfg = config.phil.server.services.calibre;
  inherit (lib) mkEnableOption mkIf mkOption types;
in {
  options = {
    phil.server.services.calibre = {
      enable = mkEnableOption "Calibre-Web";

      host = mkOption {
        description = "host for reverse proxy";
        type = types.str;
        default = "calibre";
      };

      port = mkOption {
        type = types.port;
        default = netlib.portFor "calibreweb";
        description = ''
          Listen port for Calibre-Web.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "nixos";
        description = "User account under which Calibre-Web runs.";
      };

      calibreLibrary = mkOption {
        type = types.nullOr types.str;
        default = "${config.phil.server.services.syncthing.dataDir}/calibre_folder";
        description = ''
          Path to Calibre library.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    services.calibre-web = {
      inherit (cfg) enable;
      user = "syncthing";
      group = "syncthing";
      listen.port = cfg.port;
      listen.ip = "0.0.0.0";
      options = {
        inherit (cfg) calibreLibrary;
        enableBookConversion = true;
        enableBookUploading = true;
        enableKepubify = true;
        # TODO: keycloak auth header
        #reverseProxyAuth = true;
        #header = "";
      };
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {inherit (cfg) port;};
      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Calibre";
          subtitle = "Ebooks";
          tag = "app";
          keywords = "selfhosted books";
          logo = "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Calibre_logo_3.png/120px-Calibre_logo_3.png";
        };
      };
    };
  };
}
