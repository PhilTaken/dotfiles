{
  pkgs,
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
      default = "";
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
      # limit to external ip on alpha?
      address = "0.0.0.0";

      serverUrl = "https://headscale.${net.tld}:443";
      settings = {
        reporting-disable = true;
        http-bind-address = "${cfg.url}:${builtins.toString cfg.port}";
        #vault-addr = "10.100.0.1:8200";
      };
    };
    phil.server.services.caddy.proxy."${cfg.host}" = {inherit (cfg) port;};
  };
}
