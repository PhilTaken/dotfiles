{ pkgs
, config
, lib
, net
, ...
}:

let
  inherit (lib) mkIf types mkOption;
  cfg = config.phil.server.services.promexp;
in
{
  options.phil.server.services.promexp = {
    enable = mkOption {
      default = true;
      type = types.bool;
    };

    port = mkOption {
      type = types.port;
      default = 9002;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces."${net.networks.default.interfaceName}" = {
      allowedUDPPorts = [ cfg.port ];
      allowedTCPPorts = [ cfg.port ];
    };

    services.prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        inherit (cfg) port;
      };
    };
  };
}
