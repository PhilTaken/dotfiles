{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.server.services.grafana;
  outputUrl = "http://10.200.0.1:8086";
  domain = "grafana.home";
  port = 3010;
  net = import ../../../network.nix { };
in
{
  options.phil.server.services.grafana = {
    enable = mkEnableOption "grafana";
    inputs = {
      default = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (cfg.enable) {
    sops.secrets.grafana-adminpass = {
      owner = config.systemd.services.grafana.serviceConfig.User;
    };
    sops.secrets.grafana-admindbpass = {
      owner = config.systemd.services.grafana.serviceConfig.User;
    };

    phil.server.services.caddy.proxy."grafana" = port;

    networking.firewall.interfaces."${net.networks.default.interfaceName}" = {
      allowedUDPPorts = [ 3100 ];
      allowedTCPPorts = [ 3100 ];
    };

    services.loki = {
      enable = true;
      configuration = {
        auth_enabled = false;
        analytics.reporting_enabled = false;

        server = {
          http_listen_port = 3100;
          grpc_listen_port = 9060;
        };

        common = {
          path_prefix = "/tmp/loki";
          storage.filesystem = {
            chunks_directory = "/tmp/loki/chunks";
            rules_directory = "/tmp/loki/rules";
          };
          replication_factor = 1;
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
        };

        schema_config = {
          configs = [
            {
              from = "2020-10-24";
              store = "boltdb-shipper";
              object_store = "filesystem";
              schema = "v11";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };
        ruler.alertmanager_url = "http://localhost:9093";
      };
    };

    services.grafana = rec {
      inherit port domain;
      enable = true;
      protocol = "http";

      rootUrl = "${protocol}://${domain}/";
      addr = "0.0.0.0";

      security.adminUser = "admin";
      security.adminPasswordFile = inputs.config.sops.secrets.grafana-adminpass.path;

      database.user = "root";
      database.passwordFile = inputs.config.sops.secrets.grafana-admindbpass.path;

      provision = {
        # TODO: conditional influx data source
        datasources = [
          {
            name = "Loki";
            type = "loki";
            url = "http://localhost:3100";
          }
        ];
      };
    };
  };
}
