{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.influxdb2;
in
{

  options.phil.server.services.influxdb2 = {
    enable = mkEnableOption "influxdb2 - time series database";
    url = mkOption {
      description = "influxdb url (webinterface)";
      type = types.str;
    };

    port = mkOption {
      description = "influxdb port (webinterface)";
      type = types.port;
      default = 8086;
    };
  };

  config = mkIf (cfg.enable) {
    services.influxdb2 = {
      enable = true;
      settings = {
        reporting-disable = true;
        http-bind-address = "${cfg.url}:${builtins.toString cfg.port}";
        #vault-addr = "10.100.0.1:8200";
      };
    };
  };
}
