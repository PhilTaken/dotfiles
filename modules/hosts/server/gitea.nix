{
  config,
  lib,
  netlib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.gitea;
in {
  options.phil.server.services.gitea = {
    enable = mkEnableOption "gitea";
    url = mkOption {
      description = "gitea url (webinterface)";
      default = "https://${netlib.domainFor "gitea"}";
      type = types.str;
    };
    port = mkOption {
      description = "port for the http interface";
      type = types.port;
      default = netlib.portFor "gitea";
    };
    stateDir = mkOption {
      description = "state dir for gitea";
      type = types.str;
      default = "/media/gitea";
    };
    host = mkOption {
      type = types.str;
      default = "gitea";
    };
  };

  config = mkIf cfg.enable {
    services.forgejo = {
      inherit (cfg) stateDir enable;
      lfs.enable = true;

      package = pkgs.forgejo;

      settings = {
        DEFAULT.APP_NAME = "Oroboros";

        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
        other.SHOW_FOOTER_VERSION = false;

        server.DOMAIN = netlib.domainFor cfg.host;
        server.ROOT_URL = cfg.url;
        server.HTTP_PORT = cfg.port;

        openid.ENABLE_OPENID_SIGNUP = true;
        oauth2_client.ENABLE_AUTO_REGISTRATION = true;
        oauth2_client.UPDATE_AVATAR = true;
        # oauth2_client.OPENID_CONNECT_SCOPES = ["roles"];
      };
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {
        inherit (cfg) port;
        public = true;
      };

      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Gitea";
          subtitle = "Git Server";
          tag = "app";
          keywords = "selfhosted git";
          logo = "https://gitea.io/images/gitea.png";
        };
      };
    };
  };
}
