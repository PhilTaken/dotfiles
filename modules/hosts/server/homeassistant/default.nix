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

    services.home-assistant = {
      inherit (cfg) enable;

      extraPackages =
        ps: with ps; [
          gtts
          aio-ownet
          pyairnow
          getmac
          fritzconnection
          accuweather
          py-cpuinfo
          python-kasa
          hatasmota
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
        "uptime"

        # requires extra input on ui
        "fritzbox"
        "met"
        "here_travel_time"
        "tasmota"
      ];

      customComponents = [
        (pkgs.home-assistant.python.pkgs.callPackage ./ha-bambulab.nix { })
      ];

      config =
        let
          home_zone_name = "home";
          work_zone_name = "work";
        in
        {
          default_config = { };

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
                  service = "notify.mobile_app_jaid_s_phone";
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
            ]
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
          };

          python_script = { };
        };
    };

    phil.server.services = {
      caddy.proxy."mqtt".port = 1883;

      caddy.proxy."${cfg.host}" = {
        inherit (cfg) port;
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
