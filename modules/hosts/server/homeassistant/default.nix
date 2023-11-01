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
    sops.secrets.mqtt-password = {
      owner = "mosquitto";
      restartUnits = ["mosquitto.service"];
    };

    systemd.tmpfiles.rules = ["L+ ${config.services.home-assistant.configDir}/python_scripts - - - - ${./python-scripts}"];

    # ----------------
    # mqtt
    services.mosquitto = {
      enable = true;
      listeners = [
        {
          users.root = {
            acl = ["readwrite #"];
            passwordFile = config.sops.secrets.mqtt-password.path;
          };
        }
      ];
    };
    networking.firewall.allowedTCPPorts = [1883];

    # ----------------

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
          py-cpuinfo
          python-kasa
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
        "air_quality"
        "python_script"
        "mqtt"

        # requires extra input on ui
        "fritzbox"
        "hue"
        "met"
        "openweathermap"
        "here_travel_time"
        "jellyfin"

        # TODO
        #"command_line"
        #"device_tracker"
        #"feedreader"
        #"gtfs" # https://gtfs.de/en/feeds/de_full/
      ];

      config = let
        home_zone_name = "home";
        work_zone_name = "work";
      in {
        default_config = {};

        logger.default = "info";

        input_select = {
          here_destination_preset.options = [
            "zone.${home_zone_name}"
            "zone.${work_zone_name}"
          ];
          here_origin_preset.options = [
            "zone.${home_zone_name}"
            "zone.${work_zone_name}"
          ];
        };

        automation = [
          {
            id = "speaker_on_off_with_desktop";
            alias = "Speakers - turn on and off with the desktop";
            initial_state = "on";
            trigger = [
              {
                platform = "state";
                entity_id = "!secret desktop_device_id";
                from = null;
              }
            ];
            action = [
              {
                service = "python_script.desktop_speakers_sync";
                data = {
                  desktop_entity = "!secret desktop_device_id";
                  speaker_entity = "!secret speaker_device_id";
                  inherit home_zone_name;
                };
              }
            ];
          }
        ];

        zone = [
          {
            name = work_zone_name;
            icon = "mdi:briefcase";
            latitude = "!secret work_latitude";
            longitude = "!secret work_longitude";
            radius = "200";
          }
        ];

        http = {
          use_x_forwarded_for = true;
          trusted_proxies =
            ["127.0.0.1"]
            ++ (map (endpoint: net.networks.yggdrasil.hosts.${endpoint}) (builtins.attrNames net.endpoints))
            ++ lib.optional (builtins.hasAttr config.networking.hostName net.networks.lan) net.networks.lan.${config.networking.hostName};
          server_port = cfg.port;
          server_host = ["0.0.0.0"];
        };

        sensor = [
          {
            platform = "dwd_weather_warnings";
            region_name = "!secret dwd_region_name";
          }
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
            url = "!secret caldav_url";
            custom_calendars = [
              {
                name = "work";
                calendar = "work";
                search = ".*";
              }
              {
                name = "Personal";
                calendar = "Personal";
                search = ".*";
              }
            ];
          }
          # TODO: set up a cache
          #{
          #platform = "caldav";
          #url = "!secret work_caldav_url";
          #username = "!secret work_caldav_username";
          #password = "!secret work_caldav_password";
          #custom_calendars = [{
          #name = "Work";
          #calendar = "Arbeit";
          #search = ".*";
          #}];
          #}
        ];

        lovelace.mode = "yaml";

        homeassistant = {
          name = "Home";
          latitude = "!secret latitude";
          longitude = "!secret longitude";
          elevation = "!secret elevation";
          unit_system = "metric";
          temperature_unit = "C";
          time_zone = "Europe/Amsterdam";
        };

        python_script = {};
      };
    };

    networking.firewall.interfaces.${net.networks.yggdrasil.interfaceName} = {
      allowedTCPPorts = [cfg.port];
      allowedUDPPorts = [cfg.port];
    };

    phil.server.services = {
      caddy.proxy."mqtt" = {
        inherit (cfg) port;
      };

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
