{
  config,
  lib,
  netlib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf types;
  cfg = config.phil.server.services.keycloak;
in {
  options.phil.server.services.keycloak = {
    enable = mkEnableOption "keycloak";

    https-port = mkOption {
      type = types.port;
      default = netlib.portFor "keycloak";
    };

    http-port = mkOption {
      type = types.port;
      default = netlib.portFor "keycloak-https";
    };

    host = mkOption {
      type = types.str;
      default = "keycloak";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.keycloak-dbpass = {};

    services.keycloak = {
      inherit (cfg) enable;
      database = {
        passwordFile = config.sops.secrets.keycloak-dbpass.path;
      };
      settings = {
        hostname = netlib.domainFor cfg.host;
        proxy-headers = "xforwarded";
        http-enabled = true;
        inherit (cfg) http-port https-port;
      };
      initialAdminPassword = "unsafe-password";
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {
        port = cfg.http-port;
        public = true;
      };
      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Keycloak";
          subtitle = "Authentication";
          tag = "app";
          keywords = "selfhosted security";
          logo = "https://pbs.twimg.com/profile_images/702119821979344897/oAC05cEB_400x400.png";
        };
      };
    };
  };
}
