{
  pkgs,
  config,
  lib,
  netlib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.mealie;
in {
  options.phil.server.services.mealie = {
    enable = mkEnableOption "mealie - recipe manager";
    url = mkOption {
      description = "mealie url (webinterface)";
      type = types.str;
      default = netlib.domainFor cfg.host;
    };

    port = mkOption {
      description = "webinterface port";
      type = types.port;
      default = netlib.portFor "mealie";
    };

    host = mkOption {
      type = types.str;
      default = "mealie";
    };
  };

  config = mkIf cfg.enable {
    services.mealie = {
      enable = true;

      listenAddress = "0.0.0.0";
      inherit (cfg) port;

      settings = {
        # general
        BASE_URL = cfg.url;
        API_PORT = 9000;
        TZ = "Europe/Berlin";
        ALLOW_SIGNUP = "false";
        DB_ENGINE = "sqlite";

        # oidc
        OIDC_AUTH_ENABLED = "true";
        OIDC_SIGNUP_ENABLED = "true";
        OIDC_CONFIGURATION_URL = "https://keycloak.pherzog.xyz/realms/services/.well-known/openid-configuration";
        OIDC_CLIENT_ID = "mealie";
        OIDC_PROVIDER_NAME = "Keycloak";
        OIDC_AUTO_REDIRECT = "true";
      };
    };

    phil.server.services.caddy.proxy."${cfg.host}" = {inherit (cfg) port;};
  };
}
