{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.telegraf;
  outputUrl = "http://10.200.0.1:8086";
in {
  options.phil.server.services.telegraf = {
    enable = mkEnableOption "telegraf";
    inputs = {
      default = mkOption {
        type = types.bool;
        default = true;
      };

      extrasensors = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (cfg.enable) {
    sops.secrets.telegraf-shared = mkIf (cfg.enable) {
      owner = config.systemd.services.telegraf.serviceConfig.User;
      sopsFile = ../../../sops/telegraf.yaml;
    };

    users.users.telegraf.extraGroups = [ "dialout" ];

    services.telegraf = {
      enable = true;
      environmentFiles = [
        config.sops.secrets.telegraf-shared.path
        (pkgs.writeTextFile {
          name = "telegraf-path-env";
          text = ''
            PATH="$PATH:${pkgs.lm_sensors}/bin"
          '';
        })
      ];
      extraConfig = {
        agent = {
          interval = "10s";
          round_interval = true;
          metric_batch_size = 2000;
          metric_buffer_limit = 100000;
          collection_jitter = "0s";
          flush_interval = "20s";
          flush_jitter = "0s";
          precision = "";
          debug = false;
          quiet = false;
          logfile = "";
          hostname = "";
          omit_hostname = false;
        };

        outputs = {
          influxdb_v2 = [
            {
              urls = [ outputUrl ];
              timeout = "10s";
              token = "$INFLUX_TOKEN";
              organization = "home";
              bucket = "data";
              namepass = [ "cpu" "disk" "diskio" "mem" "net" "processes" "swap" "system" "sensors" ];
            }
          ] ++ (lib.optional cfg.inputs.extrasensors {
            urls = [ outputUrl ];
            timeout = "10s";
            token = "$INFLUX_TOKEN";
            organization = "home";
            bucket = "sensors";
            namepass = [ "env_sensors" ];
          });
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
          sensors = { };
        } // (lib.optionalAttrs cfg.inputs.extrasensors {
          tail = {
            name_override = "env_sensors";
            files = [ "/dev/serial/by-id/usb-Adafruit_QT2040_Trinkey_DF609C8067563726-if00" ];
            precision = "100ms";
            pipe = true;
            data_format = "json";
            json_strict = "true";
          };
        });
      };
    };
  };
}
