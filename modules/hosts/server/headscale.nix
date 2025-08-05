{
  config,
  lib,
  netlib,
  ...
}: let
  inherit
    (lib)
    mkOption
    mkIf
    types
    mkEnableOption
    ;
  cfg = config.phil.server.services.headscale;
  net = config.phil.network;
in {
  options.phil.server.services.headscale = {
    enable = mkEnableOption "headscale - time series database";
    url = mkOption {
      description = "headscale url (webinterface)";
      type = types.str;
      default = netlib.domainFor cfg.host;
    };

    port = mkOption {
      description = "headscale port (webinterface)";
      type = types.port;
      default = netlib.portFor "headscale";
    };

    host = mkOption {
      type = types.str;
      default = "headscale";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."headscale-kc-client-secret".owner =
      config.systemd.services.headscale.serviceConfig.User;

    services.headscale = {
      enable = true;
      # limit to external ip on beta?
      address = "0.0.0.0";
      inherit (cfg) port;

      settings = {
        server_url = "https://${cfg.url}";
        reporting-disable = true;
        logtail.enable = false;

        dns = {
          nameservers.global = lib.mapAttrsToList (_: v: v.network_ip."headscale") (
            netlib.nodesWith "unbound"
          );
          override_local_dns = true;

          magic_dns = false;
          base_domain = "";
        };
        oidc = {
          client_secret_path = config.sops.secrets."headscale-kc-client-secret".path;
          # TODO network.nix?
          issuer = "https://${netlib.domainFor "keycloak"}/realms/services";
          client_id = "headscale";
        };
      };
    };

    systemd.services."headscale" = lib.mkIf config.phil.server.services.keycloak.enable {
      after = ["keycloak.service"];
      requires = ["keycloak.service"];

      # https://github.com/juanfont/headscale/issues/1574
      # remove after update to 0.23.0
      serviceConfig.TimeoutStopSec = 5;
    };

    phil.server.services.caddy.proxy."${cfg.host}" = {
      inherit (cfg) port;
      public = true;
    };
  };
}
