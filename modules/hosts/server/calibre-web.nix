{ config, lib, pkgs, ... }:

let
  cfg = config.phil.server.services.calibre;

  inherit (lib) concatStringsSep mkEnableOption mkIf mkOption optional optionalString types;
in
{
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
        default = 8083;
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
        default = "/media/syncthing/data/calibre_folder";
        description = ''
          Path to Calibre library.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    services.calibre-web = {
      inherit (cfg) user enable;
      listen.port = cfg.port;
      options = {
        inherit (cfg) calibreLibrary;
        enableBookConversion = true;
        enableBookUploading = true;
        # TODO: keycloak auth header
        #reverseProxyAuth = true;
        #header = "";
      };
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = { inherit (cfg) port; };
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
