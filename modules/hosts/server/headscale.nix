{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.headscale;
  net = config.phil.network;
in {
  options.phil.server.services.headscale = {
    enable = mkEnableOption "headscale - time series database";
    url = mkOption {
      description = "headscale url (webinterface)";
      type = types.str;
      default = "${cfg.host}.${net.tld}";
    };

    port = mkOption {
      description = "headscale port (webinterface)";
      type = types.port;
      default = 8086;
    };

    host = mkOption {
      type = types.str;
      default = "headscale";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."headscale-kc-client-secret".owner = config.systemd.services.headscale.serviceConfig.User;

    services.headscale = {
      enable = true;
      # limit to external ip on beta?
      address = "0.0.0.0";
      inherit (cfg) port;

      settings = {
        server_url = "https://${cfg.url}";
        reporting-disable = true;
        dns_config = {
          base_domain = net.tld;

          # TODO change from fixed ip to derived from network.nix
          nameservers = ["100.64.0.3"];
          override_local_dns = true;
        };
        oidc = {
          only_start_if_oidc_is_available = true;
          client_secret_path = config.sops.secrets."headscale-kc-client-secret".path;
          # TODO network.nix?
          issuer = "https://keycloak.pherzog.xyz/realms/services";
          client_id = "headscale";
        };
      };
    };

    phil.server.services.caddy.proxy."${cfg.host}" = {
      inherit (cfg) port;
      public = true;
    };
  };
}
