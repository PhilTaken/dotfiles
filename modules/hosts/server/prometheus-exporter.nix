{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkEnableOption mkIf types mkOption;
  cfg = config.phil.server.services.promexp;
  loki_url = "10.200.0.1:3100";
in
{
  options.phil.server.services.promexp = {
    enable = mkOption {
      default = true;
      type = types.bool;
    };

    port = mkOption {
      type = types.port;
      default = 3103;
    };
  };

  config = mkIf cfg.enable {
    services.prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
  };
}
