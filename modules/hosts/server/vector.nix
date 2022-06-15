{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.vector;
  loki_url = "10.200.0.1:3100";
in {
  options.phil.server.services.vector = {
    enable = mkOption {
      description = "enable the vector module";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    services.vector = {
      enable = true;
      journaldAccess = true;

      settings = {
        timezone = "local";

        sources = {
          journald = {
            acknowledgements.enabled = true;
            type = "journald";
            include_units = [];
            current_boot_only = true;
            exclude_matches.SYSLOG_IDENTIFIER = [ "xsession" ];
            since_now = true;
          };
        };

        transforms = {
        };

        sinks = {
          loki = {
            acknowledgements.enabled = false;
            type = "loki";
            inputs = [ "journald" ];
            endpoint = "http://${loki_url}/";
            compression = "none";
            remove_timestamp = true;
            remove_label_fields = true;

            labels = {
              forwarder = "vector";
              event = "{{ event_field }}";
            };

            encoding.codec = "logfmt";
          };

          #out = {
            #inputs = [
              #"journald"
            #];
            #encoding.codec = "text";

            #type = "file";
            #path = "/var/lib/vector/test.log";
          #};
        };
      };
    };
  };
}
