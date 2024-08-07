{
  config,
  lib,
  netlib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.influxdb2;
in {
  options.phil.server.services.influxdb2 = {
    enable = mkEnableOption "influxdb2 - time series database";
    url = mkOption {
      description = "influxdb url (webinterface)";
      type = types.str;
      default = netlib.domainFor "influx";
    };

    port = mkOption {
      description = "influxdb port (webinterface)";
      type = types.port;
      default = netlib.portFor "influxdb";
    };

    host = mkOption {
      type = types.str;
      default = "influx";
    };
  };

  config = mkIf cfg.enable {
    services.influxdb2 = {
      enable = true;
      settings = {
        reporting-disable = true;
        http-bind-address = "${cfg.url}:${builtins.toString cfg.port}";
        #vault-addr = "10.100.0.1:8200";
      };
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {inherit (cfg) port;};
      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "InfluxDB 2";
          subtitle = "TSDB";
          tag = "app";
          keywords = "selfhosted data";
          logo = "https://gitlab.com/uploads/-/system/project/avatar/18447221/255-2551990_influxdb-logo-png-transparent-png.png";
        };
      };
    };
  };
}
