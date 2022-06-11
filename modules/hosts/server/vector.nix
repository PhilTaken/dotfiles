{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.vector;
  url = "10.200.0.1:";
in {
  options.phil.server.services.vector = {
    enable = mkEnableOption "vector";
  };

  config = mkIf (cfg.enable) {
    services.vector = {
      enable = true;
      journaldAccess = true;

      settings = {
        timezone = "local";
        sources = {
          journald = {
            type = "journald";
            include_units = [];
            current_boot_only = true;
            exclude_matches.SYSLOG_IDENTIFIER = [ "xsession" ];
            acknowledgements.enabled = true;
            since_now = true;
          };
        };
        sinks.out = {
          inputs = [ "journald" ];
          encoding.codec = "text";

          type = "file";
          path = "/var/lib/vector/test.log";
        };
      };
    };
  };
}
