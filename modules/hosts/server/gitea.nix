{ pkgs
, config
, lib
, net
, ...
}:

let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.gitea;
in
{

  options.phil.server.services.gitea = {
    enable = mkEnableOption "gitea";
    url = mkOption {
      description = "gitea url (webinterface)";
      default = "https://gitea.${net.tld}";
      type = types.str;
    };
    port = mkOption {
      description = "port for the http interface";
      type = types.port;
      default = 3000;
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
    services.gitea = {
      inherit (cfg) stateDir enable;

      domain = "${cfg.host}.${net.tld}";
      rootUrl = "https://${cfg.host}.${net.tld}/";

      httpPort = cfg.port;
      #ssh.enable = true;
      lfs.enable = true;
      settings.session.COOKIE_SECURE = true;
      appName = "Oroboros";
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = { inherit (cfg) port; };
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
