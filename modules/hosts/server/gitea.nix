{
  config,
  lib,
  net,
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
      package = pkgs.forgejo;
      lfs.enable = true;
      appName = "Oroboros";

      settings = {
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
        other.SHOW_FOOTER_VERSION = false;

        server.DOMAIN = "${cfg.host}.${net.tld}";
        server.ROOT_URL = "https://${cfg.host}.${net.tld}/";
        server.HTTP_PORT = cfg.port;
      };
    };

    networking.firewall.interfaces.${net.networks.yggdrasil.interfaceName} = {
      allowedTCPPorts = [cfg.port];
      allowedUDPPorts = [cfg.port];
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
