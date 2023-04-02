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
    services.vector = {
      enable = true;
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
