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
  pkgs,
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
  net = config.phil.network;
in
{
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
      default = netlib.portFor "homeassistant";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."home-assistant-secrets.yaml" = {
      owner = "hass";
      path = "/var/lib/hass/secrets.yaml";
      restartUnits = [ "home-assistant.service" ];
    };
    sops.secrets.mqtt-password = {
      owner = "mosquitto";
      restartUnits = [ "mosquitto.service" ];
    };

    systemd.tmpfiles.rules = [
      "L+ ${config.services.home-assistant.configDir}/python_scripts - - - - ${./python-scripts}"
    ];

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

    systemd.services.home-assistant = {
      preStart = lib.mkBefore ''
        touch -a ${config.services.home-assistant.configDir}/{automations,scenes,scripts,manual}.yaml
      '';
    };

    services.home-assistant = {
      inherit (cfg) enable;

      extraPackages =
        ps: with ps; [
          accuweather
          adguardhome
          aio-ownet
          aioelectricitymaps
          dwdwfsapi
          fritzconnection
          getmac
          gtts
          psycopg2
          py-cpuinfo
          pyairnow
          pyipp
          pymodbus
          python-kasa
          zlib-ng
        ];

      extraComponents = [
        "air_quality"
        "apple_tv"
        "calendar"
        "cover"
        "derivative"
        "esphome"
        "forecast_solar"
        "fritzbox"
        "geo_location"
        "here_travel_time"
        "homekit"
        "light"
        "met"
        "moon"
        "mqtt"
        "python_script"
        "radio_browser"
        "shelly"
        "shelly"
        "shopping_list"
        "spotify"
        "tasmota"
        "uptime"
        "wyoming"
        "zha"
      ];

      customComponents = [
        (pkgs.home-assistant.python.pkgs.callPackage ./ha-bambulab.nix { })
      ];

      customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
        (pkgs.callPackage ./hui-element.nix { })
        (pkgs.callPackage ./config-template-card.nix { })
        apexcharts-card
        bubble-card
        button-card
        card-mod
        clock-weather-card
        hourly-weather
        mini-graph-card
        multiple-entity-row
        mushroom
        weather-card
        weather-chart-card
      ];

      config =
        let
          home_zone_name = "home";
          work_zone_name = "work";
        in
        {
          default_config = { };

          # TODO fix scenes
          lovelace.mode = "yaml";

          # frontend.themes = "!include_dir_merge_named themes";
          "automation ui" = "!include automations.yaml";
          "scene" = "!include scenes.yaml";

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
                  entity_id = "device_tracker.desktop_l9ck0qi";
                  from = null;
                }
              ];
              action = [
                {
                  service = "python_script.desktop_speakers_sync";
                  data = {
                    desktop_entity = "device_tracker.desktop_l9ck0qi";
                    speaker_entity = "switch.sound";
                    inherit home_zone_name;
                  };
                }
              ];
            }

            {
              mode = "single";
              triggers = [
                {
                  device_id = "e4286e54c4270366223cf92787b32ad1";
                  domain = "bambu_lab";
                  type = "event_print_finished";
                  trigger = "device";
                }
              ];
              actions = [
                {
                  action = "notify.mobile_app_phil_op7";
                  data.message = "Print finished!";
                }
              ];
            }
            {
              mode = "single";
              triggers = [
                {
                  device_id = "e4286e54c4270366223cf92787b32ad1";
                  domain = "bambu_lab";
                  type = "event_print_error";
                  trigger = "device";
                }
              ];
              actions = [
                {
                  action = "notify.mobile_app_phil_op7";
                  data.message = "Print error!";
                }
              ];
            }

            {
              alias = "washing_machine_done_notification";
              trigger = [
                {
                  platform = "numeric_state";
                  entity_id = "sensor.washer_sensor_power";
                  below = 10;
                  for.minutes = 5;
                }
              ];

              condition = [
                {
                  alias = "up for more than 15 minutes";
                  condition = "template";
                  value_template = ''
                    {% set value = states('sensor.uptime') %}
                    {% set up_minutes = (now().timestamp() - as_timestamp(value)) / 60 %}
                    {{ up_minutes > 15 }}
                  '';
                }
              ];

              action = [
                {
                  service = "notify.mobile_app_phil_op7";
                  data.message = "Washing machine is done!";
                }
                {
                  service = "notify.mobile_app_whinn";
                  data.message = "Washing machine is done!";
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
            trusted_proxies = [
              "127.0.0.1"
              "100.64.0.25"
            ]
            ++ (builtins.filter (v: v != null) (builtins.catAttrs "public_ip" (builtins.attrValues net.nodes)))
            ++ (builtins.filter (v: v != null) (builtins.catAttrs "public_ip" (builtins.attrValues net.nodes)))
            ++ lib.optional (
              net.nodes.${config.networking.hostName}.network_ip ? "lan"
            ) net.nodes.${config.networking.hostName}.network_ip."lan";
            server_port = cfg.port;
          };

          sensor = [
            {
              platform = "dwd_weather_warnings";
              region_name = "!secret dwd_region_name";
            }
          ];

          mqtt = [
            {
              sensor = {
                name = "washer_sensors_status";
                json_attributes_topic = "tele/pantrysocket/SENSOR";
                json_attributes_template = "{{ value_json.ENERGY | tojson }}";

                state_topic = "tele/pantrysocket/STATE";
                value_template = "{{ value_json.POWER }}";
              };
            }

            {
              switch = {
                name = "washer_switch";
                command_topic = "cmnd/pantrysocket/Power";

                state_topic = "tele/pantrysocket/STATE";
                value_template = "{{ value_json.POWER }}";
              };
            }
          ]
          ++ (map
            (d: {
              sensor = {
                name = "washer_sensor_${d.name}";
                state_topic = "tele/pantrysocket/SENSOR";
                value_template = "{{ value_json.ENERGY.${d.name} }}";
                unit_of_measurement = d.unit;
              };
            })
            [
              {
                name = "Total";
                unit = "kWh";
              }
              {
                name = "Power";
                unit = "W";
              }
              {
                name = "Voltage";
                unit = "V";
              }
              {
                name = "Current";
                unit = "A";
              }
            ]
          );

          calendar = [ ];

          homeassistant = {
            name = "Home";
            latitude = "!secret latitude";
            longitude = "!secret longitude";
            elevation = "!secret elevation";
            unit_system = "metric";
            temperature_unit = "C";
            time_zone = "Europe/Amsterdam";
            packages.manual = "!include manual.yaml";
          };

          python_script = { };
        };
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
