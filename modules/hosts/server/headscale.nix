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
    services.headscale = {
      enable = true;
      # limit to external ip on beta?
      address = "0.0.0.0";

      serverUrl = cfg.url;
      settings = {
        reporting-disable = true;
        dns_config.base_domain = net.tld;
      };
    };
    phil.server.services.caddy.proxy."${cfg.host}" = {inherit (cfg) port;};
  };
}
