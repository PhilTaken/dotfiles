{
  config,
  lib,
  netlib,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.phil.server.services.vector;
  net = config.phil.network;

  promtail_client = builtins.head (builtins.attrNames (lib.filterAttrs (_: v: builtins.elem "grafana" v.services) net.nodes));
  pm_client_ip = net.nodes.${promtail_client}.network_ip."headscale";

  # TODO: consul?
  pm_client_port = netlib.portFor "loki";
in {
  options.phil.server.services.vector = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    users.users.promtail.extraGroups = ["nginx"];

    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 28183;
          grpc_listen_port = 0;
        };

        positions.filename = "/tmp/positions.yaml";

        clients = [{url = "http://${pm_client_ip}:${builtins.toString pm_client_port}/loki/api/v1/push";}];

        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = config.networking.hostName;
              };
            };
            relabel_configs = [
              {
                source_labels = ["__journal__systemd_unit"];
                target_label = "unit";
              }
            ];
          }

          {
            job_name = "nginx_analytics";
            static_configs = [
              {
                targets = ["localhost"];
                labels = {
                  job = "nginx_analytics";
                  host = config.networking.hostName;
                  __path__ = "/var/log/nginx/analytics*log";
                };
              }
            ];
            pipeline_stages = [
              {
                json.expressions = {
                  request_uri = "request_uri";
                  http_referer = "http_referer";
                  http_referer_base = "http_referer";
                };
              }
              {
                regex = {
                  expression = "^(?P<http_referer_base>[^?]+)\\?.*";
                  source = "http_referer";
                };
              }
              {
                drop = {
                  source = "request_uri";
                  expression = ".*git-upload-pack$";
                };
              }
              {
                drop = {
                  source = "request_uri";
                  expression = "\\/(api|assests|img)\\/.*";
                };
              }
              {
                drop = {
                  source = "request_uri";
                  expression = "\\/loki\\/api\\/v1\\/push";
                };
              }
              {
                drop = {
                  source = "request_uri";
                  expression = "\\/(lovelave|service_worker\\.js).*";
                };
              }
              {
                drop = {
                  source = "request_uri";
                  expression = "\\/(index|remote)\\.php.*";
                };
              }
            ];
          }
        ];
      };
    };
  };
}
