{ config
, lib
, net
, ...
}:

let
  inherit (lib) mkOption mkIf types;
  cfg = config.phil.server.services.vector;
in
{
  options.phil.server.services.vector = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 28183;
          grpc_listen_port = 0;
        };

        positions.filename = "/tmp/positions.yaml";

        clients = [{ url = "https://loki.${net.tld}/loki/api/v1/push"; }];

        scrape_configs = [{
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = config.networking.hostName;
            };
          };
          relabel_configs = [{
            source_labels = ["__journal__systemd_unit"];
            target_label = "unit";
          }];
        }];
      };
    };

    services.vector = {
      enable = false;
      journaldAccess = true;

      settings = {
        timezone = "local";

        sources = {
          journald = {
            acknowledgements.enabled = true;
            type = "journald";
            include_units = [ ];
            current_boot_only = true;
            exclude_matches.SYSLOG_IDENTIFIER = [ "xsession" ];
            since_now = true;
          };
        };

        transforms = { };

        sinks = {
          loki = {
            acknowledgements.enabled = false;
            type = "loki";
            inputs = [ "journald" ];
            endpoint = "https://loki.${net.tld}/";
            compression = "none";
            remove_timestamp = true;
            remove_label_fields = true;

            labels = {
              forwarder = "vector";
              event = "{{ event_field }}";
            };

            encoding.codec = "logfmt";
          };
        };
      };
    };
  };
}
