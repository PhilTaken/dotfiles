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
  imports = [
  ];

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
    sops.secrets."home-assistant-secrets.yaml" = {
      owner = "hass";
      path = "/var/lib/hass/secrets.yaml";
      restartUnits = ["home-assistant.service"];
    };

    services.home-assistant = {
      inherit (cfg) enable;

      extraPackages = ps:
        with ps; [
          gtts
          pyownet
          pyairnow
          getmac
          fritzconnection
          accuweather
        ];

      extraComponents = [
        # TODO with extra hardware
        # "bluetooth"
        # "bluetooth_le_tracker"
        # "esphome"

        # simple setup, plug and play
        "calendar"
        "cover"
        "derivative"
        "geo_location"
        "light"
        "moon"
        "radio_browser"
        "shopping_list"

        # requires extra input on ui
        "dwd_weather_warnings"
        "fritzbox"
        "hue"
        "jellyfin"
        "met"
        "openweathermap"
        "here_travel_time"

        # done in yaml config, maybe remove?
        "caldav"
        "waqi"

        # TODO
        #"air_quality"
        #"command_line"
        #"device_tracker"
        #"feedreader"
        #"gtfs" # https://gtfs.de/en/feeds/de_full/

        # maybe
        #"downloader"
      ];

      config = {
        default_config = {};

        input_select = {
          here_destination_preset.options = [
            "zone.home"
            "zone.work"
          ];
          here_origin_preset.options = [
            "zone.home"
            "zone.work"
          ];
        };

        automation = [
          {
            id = "update_morning_commute_sensor";
            alias = "Commute - Update morning commute sensor";
            initial_state = "on";
            trigger = [
              {
                platform = "time_pattern";
                minutes = "/5";
              }
            ];
            condition = [
              {
                condition = "time";
                after = "08:00:00";
                before = "11:00:00";
              }
              {
                condition = "time";
                weekday = [
                  "mon"
                  "tue"
                  "wed"
                  "thu"
                  "fri"
                ];
              }
            ];
            action = [
              {
                service = "homeassistant.update_entity";
                target.entity_id = "sensor.morning_commute";
              }
            ];
          }
        ];

        zone = [
          {
            name = "work";
            icon = "mdi:briefcase";
            latitude = "!secret work_latitude";
            longitude = "!secret work_longitude";
            radius = "200";
          }
        ];

        http = {
          use_x_forwarded_for = true;
          trusted_proxies = map (endpoint: net.networks.yggdrasil.${endpoint}) (builtins.attrNames net.networks.endpoints);
          server_port = cfg.port;
          server_host = ["0.0.0.0"];
        };

        sensor = [
          {
            platform = "waqi";
            token = "!secret waqi_token";
            locations = "!secret waqi_locations";
            stations = "!secret waqi_stations";
          }
        ];

        calendar = [
          {
            platform = "caldav";
            username = "!secret caldav_username";
            password = "!secret caldav_password";
            url = "https://nextcloud.pherzog.xyz/remote.php/dav";
          }
        ];

        lovelace.mode = "yaml";

        homeassistant = {
          name = "Home";
          # TODO set up secrets w/ age
          latitude = "!secret latitude";
          longitude = "!secret longitude";
          elevation = "!secret elevation";
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
