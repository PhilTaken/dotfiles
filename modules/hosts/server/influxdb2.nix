{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.influxdb2;
  net = import ../../../network.nix { };
in
{
  options.phil.server.services.influxdb2 = {
    enable = mkEnableOption "influxdb2 - time series database";
    url = mkOption {
      description = "influxdb url (webinterface)";
      type = types.str;
      default = "";
    };

    port = mkOption {
      description = "influxdb port (webinterface)";
      type = types.port;
      default = 8086;
    };

    host = mkOption {
      type = types.str;
      default = "influx";
    };
  };

  config = mkIf (cfg.enable) {
    networking.firewall.interfaces."${net.networks.default.interfaceName}" = {
      allowedUDPPorts = [ cfg.port ];
      allowedTCPPorts = [ cfg.port ];
    };
    services.influxdb2 = {
      enable = true;
      settings = {
        reporting-disable = true;
        http-bind-address = "${cfg.url}:${builtins.toString cfg.port}";
        #vault-addr = "10.100.0.1:8200";
      };
    };
    phil.server.services.caddy.proxy."${cfg.host}" = cfg.port;
  };
}
