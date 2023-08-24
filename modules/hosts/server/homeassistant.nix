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
  net,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.homeassistant;
in {
  options.phil.server.services.homeassistant = {
    enable = mkEnableOption "homeassistant";
    datadir = mkOption {
      type = types.str;
      default = "/media/homeassistant/";
    };

    host = mkOption {
      type = types.str;
      default = "home";
    };

    port = mkOption {
      type = types.port;
      default = 8123;
    };
  };

  config = mkIf cfg.enable {
    services.home-assistant = {
      inherit (cfg) enable;
      extraComponents = [
        "esphome"
        "met"
        "radio_browser"
        "hue"
        "openweathermap"
        "air_quality"
        "fritzbox"
        "bluetooth"
        "bluetooth_le_tracker"
        "caldav"
        "calendar"
        "command_line"
        "cover"
        "derivative"
        "dwd_weather_warnings"
        "device_tracker"
        "feedreader"
        "gtfs" # https://gtfs.de/en/feeds/de_full/
        "geo_location"
        "downloader"
        "jellyfin"
        "light"
        "moon"
        "shopping_list"
        "waqi"
      ];

      config = {
        default_config = {};
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = map (endpoint: net.networks.yggdrasil.${endpoint}) (builtins.attrNames net.networks.endpoints);
          server_port = cfg.port;
          server_host = ["0.0.0.0"];
        };

        lovelace.mode = "yaml";

        homeassistant = {
          name = "Home";
          # TODO set up secrets w/ age
          #latitude = "!secret latitude";
          #longitude = "!secret longitude";
          #elevation = "!secret elevation";
          unit_system = "metric";
          temperature_unit = "C";
          time_zone = "Europe/Amsterdam";
        };
      };
    };

    networking.firewall.interfaces.${net.networks.yggdrasil.interfaceName} = {
      allowedTCPPorts = [cfg.port];
      allowedUDPPorts = [cfg.port];
    };

    phil.server.services = {
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
