{
  config,
  lib,
  net,
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
      default = "${cfg.host}.${net.tld}";
    };

    port = mkOption {
      description = "webinterface port";
      type = types.port;
      default = 8097;
    };

    host = mkOption {
      type = types.str;
      default = "mealie";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces."${net.networks.default.interfaceName}" = {
      allowedUDPPorts = [cfg.port];
      allowedTCPPorts = [cfg.port];
    };

    services.mealie = {
      enable = true;
      listenAddress = "0.0.0.0";
      inherit (cfg) port;

      settings = {
        # general
        BASE_URL = "${cfg.host}.${net.tld}";
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
      };
    };

    phil.server.services.caddy.proxy."${cfg.host}" = {
      inherit (cfg) port;
    };
  };
}
