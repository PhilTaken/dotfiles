{ pkgs
, config
, lib
, net
, flake
, ...
}:

let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.grafana;
in
{
  options.phil.server.services.grafana = {
    enable = mkEnableOption "grafana";

    host = mkOption {
      type = types.str;
      default = "grafana";
    };


    loki-port = mkOption {
      type = types.port;
      default = 3100;
    };

    prometheus-port = mkOption {
      type = types.port;
      default = 3101;
    };

    grafana-port = mkOption {
      type = types.port;
      default = 3102;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.grafana-adminpass = {
      owner = config.systemd.services.grafana.serviceConfig.User;
    };

    sops.secrets.grafana-admindbpass = {
      owner = config.systemd.services.grafana.serviceConfig.User;
    };

    networking.firewall.interfaces."${net.networks.default.interfaceName}" = {
      allowedUDPPorts = [ cfg.grafana-port cfg.loki-port cfg.prometheus-port ];
      allowedTCPPorts = [ cfg.grafana-port cfg.loki-port cfg.prometheus-port ];
    };

    services.loki = {
      enable = true;
      configuration = {
        auth_enabled = false;
        analytics.reporting_enabled = false;

        server = {
          http_listen_port = cfg.loki-port;
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

    services.prometheus = {
      enable = true;
      port = cfg.prometheus-port;

      scrapeConfigs = builtins.attrValues (lib.mapAttrs (n: v: {
        job_name = n;
        static_configs = [{
          targets = [
            "${net.networks.default.${n}}:${builtins.toString v.config.services.prometheus.exporters.node.port}"
          ];
        }];
      })
      (lib.filterAttrs (n: v: (builtins.hasAttr n net.networks.default) && (v.config.services.prometheus.exporters.node.enable)) flake.nixosConfigurations));
    };

    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_port = cfg.grafana-port;
          domain = "${cfg.host}.${net.tld}";
          protocol = "http";
          http_addr = "0.0.0.0";
        };

        security = {
          admin_user = "admin";
          admin_password = "$__file{${config.sops.secrets.grafana-adminpass.path}}";
        };

        database = {
          user = "root";
          password = "$__file{${config.sops.secrets.grafana-admindbpass.path}}";
        };
      };

      provision = {
        # TODO: conditional influx data source
        datasources.settings = {
          datasources = [
            {
              name = "Loki";
              type = "loki";
              url = "http://localhost:${builtins.toString cfg.loki-port}";
            }
          ];
        };
      };
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}".port = cfg.grafana-port;
      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Grafana";
          subtitle = "Observability Service";
          tag = "app";
          keywords = "selfhosted data";
          logo = "https://grafana.com/static/img/about/grafana_logo_swirl_fullcolor.jpg";
        };
      };
    };
  };
}
