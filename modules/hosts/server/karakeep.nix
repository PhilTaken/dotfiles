{
  config,
  lib,
  netlib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    types
    mkEnableOption
    ;
  cfg = config.phil.server.services.karakeep;
in
{
  options.phil.server.services.karakeep = {
    enable = mkEnableOption "karakeep";
    url = mkOption {
      description = "karakeep url (webinterface)";
      default = "https://${netlib.domainFor cfg.host}";
      type = types.str;
    };
    port = mkOption {
      description = "port for the http interface";
      type = types.port;
      default = netlib.portFor cfg.host;
    };
    host = mkOption {
      type = types.str;
      default = "karakeep";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.karakeep-environmentfile.owner = "karakeep";

    services.meilisearch.package = pkgs.meilisearch;

    services.karakeep = {
      inherit (cfg) enable;

      browser.enable = false;

      extraEnvironment = {
        PORT = builtins.toString cfg.port;
        DISABLE_SIGNUPS = "false";
        DISABLE_PASSWORD_AUTH = "true";
        NEXTAUTH_URL = cfg.url;
      };

      environmentFile = config.sops.secrets.karakeep-environmentfile.path;
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {
        inherit (cfg) port;
        public = false;
      };

      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Karakeep";
          subtitle = "Bookmark manager";
          tag = "app";
          keywords = "selfhosted bookmarks";
          logo = "https://karakeep.app/icons/karakeep-full.svg";
        };
      };
    };
  };
}
