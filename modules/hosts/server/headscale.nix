{
  config,
  lib,
  net,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.headscale;
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
    networking.firewall.interfaces."${net.networks.default.interfaceName}" = {
      allowedUDPPorts = [cfg.port];
      allowedTCPPorts = [cfg.port];
    };

    sops.secrets."headscale-kc-client-secret".owner = config.systemd.services.headscale.serviceConfig.User;

    services.headscale = {
      enable = true;
      # limit to external ip on beta?
      address = "0.0.0.0";
      inherit (cfg) port;

      settings = {
        server_url = "https://${cfg.url}";
        reporting-disable = true;
        dns_config.base_domain = net.tld;
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
