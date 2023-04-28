{ pkgs
, config
, lib
, net
, ...
}:

let
  inherit (lib) mkIf types mkOption mkEnableOption;
  cfg = config.phil.server.services.promexp;
in
{
  options.phil.server.services.promexp = {
    enable = mkOption {
      default = true;
      type = types.bool;
    };

    port = mkOption {
      type = types.port;
      default = 9002;
    };

    extrasensors = mkEnableOption "extra sensors";
  };

  config = mkIf cfg.enable {
    networking.firewall.interfaces."${net.networks.default.interfaceName}" = {
      allowedUDPPorts = [ cfg.port ];
      allowedTCPPorts = [ cfg.port ];
    };

    services.prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        inherit (cfg) port;
      };

      script = {
        enable = cfg.extrasensors;
        settings.scripts = [
          {
            name = "room-sensors";
            script = ''
              cat /dev/serial/by-id/usb-Adafruit_QT2040_Trinkey_DF609C8067563726-if00 | grep -v "^\$"
            '';
          }
        ];
      };
    };
  };
}
