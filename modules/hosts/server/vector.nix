{
  config,
  lib,
  net,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.phil.server.services.vector;
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

        clients = [{url = "https://loki.${net.tld}/loki/api/v1/push";}];

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
                  http_user_agent = "http_user_agent";
                  request_uri = "request_uri";
                };
              }
              {
                drop = {
                  source = "http_user_agent";
                  expression = "(bot|Bot|RSS|Producer|Expanse|spider|crawler|Crawler|Inspect|test)";
                };
              }
              {
                drop = {
                  source = "request_uri";
                  expression = "/(assets|img)/";
                };
              }
              {
                drop = {
                  source = "request_uri";
                  expression = "/(robots.txt|favicon.ico|index.php|git-upload-pack)";
                };
              }
              {
                drop = {
                  source = "request_uri";
                  expression = "(.php|.xml|.png)$";
                };
              }
              {
                drop = {
                  source = "request_uri";
                  expression = "/(api/actions|loki/api/v1/push|api/webhook)/";
                };
              }
            ];
          }
        ];
      };
    };
  };
}
