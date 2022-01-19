{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.telegraf;
in
{

  options.phil.server.services.telegraf = {
    enable = mkEnableOption "telegraf";
  };

  config = mkIf (cfg.enable) {
    sops.secrets.telegraf-shared = mkIf (cfg.enable) {
      owner = config.systemd.services.telegraf.serviceConfig.User;
      sopsFile = ../../../sops/telegraf.yaml;
    };

    services.telegraf = {
      enable = true;
      environmentFiles = [ config.sops.secrets.telegraf-shared.path ];
      extraConfig = {
        agent = {
          interval = "10s";
          round_interval = true;
          metric_batch_size = 1000;
          metric_buffer_limit = 10000;
          collection_jitter = "0s";
          flush_interval = "10s";
          flush_jitter = "0s";
          precision = "";
          debug = false;
          quiet = false;
          logfile = "";
          hostname = "";
          omit_hostname = false;
        };

        outputs = {
          influxdb_v2 = {
            urls = [ "http://alpha.yggdrasil.vpn:8086" ];
            token = "$INFLUX_TOKEN";
            organization = "home";
            bucket = "data";
          };
        };

        inputs = {
          cpu = {
            percpu = true;
            totalcpu = true;
            collect_cpu_time = false;
            report_active = false;
          };

          disk = {
            ignore_fs = [ "tmpfs" "devtmpfs" "devfs" "overlay" "aufs" "squashfs" ];
          };

          diskio = { };
          mem = { };
          net = { };
          processes = { };
          swap = { };
          system = { };
        };
      };
    };
  };
}
