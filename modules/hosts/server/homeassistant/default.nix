# Ideas
# - power outlet voltage monitor for washing machine to detect if it's running
# - window sensors
# - door sensors
# - overview panel in hallway
# - expose items to prometheus?
#   - https://www.home-assistant.io/integrations/prometheus/
# - https://gist.github.com/ffenix113/9f58aee7697a1d0756125ac93b5a27e8
{
  config,
  lib,
  netlib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    types
    mkEnableOption
    ;
  cfg = config.phil.server.services.homeassistant;
in
{
  options.phil.server.services.homeassistant = {
    enable = mkEnableOption "homeassistant";

    host = mkOption {
      type = types.str;
      default = "home";
    };

    port = mkOption {
      type = types.port;
      default = netlib.portFor "homeassistant";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.mqtt-password = {
      owner = "mosquitto";
      restartUnits = [ "mosquitto.service" ];
    };

    # ----------------
    # mqtt
    services.mosquitto = {
      enable = true;
      listeners = [
        {
          users.root = {
            acl = [ "readwrite #" ];
            passwordFile = config.sops.secrets.mqtt-password.path;
          };
        }
      ];
    };
    networking.firewall.allowedTCPPorts = [ 1883 ];

    # ----------------

    virtualisation.oci-containers.containers."homeassistant" = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      privileged = true;
      pull = "missing";
      extraOptions = [ "--network=host" ];
      volumes = [
        "/var/lib/hass:/config"
        "/run/dbus:/run/dbus:ro"
        "/etc/localtime:/etc/localtime:ro"
      ];
    };

    phil.server.services = {
      caddy.proxy."mqtt".port = 1883;

      caddy.proxy."${cfg.host}" = {
        inherit (cfg) port;
        public = true;
      };

      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Home Assistant";
          subtitle = "automate your life";
          tag = "app";
          keywords = "automation home";
          logo = "https://design.home-assistant.io/images/logo-variants.png";
        };
      };
    };
  };
}
