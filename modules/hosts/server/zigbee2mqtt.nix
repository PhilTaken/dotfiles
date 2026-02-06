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
  service_name = "zigbee2mqtt";
  cfg = config.phil.server.services.${service_name};
in
{
  options.phil.server.services.${service_name} = {
    enable = mkEnableOption service_name;
    host = mkOption {
      description = "domain for ${service_name}";
      type = types.str;
      default = service_name;
    };

    port = mkOption {
      type = types.port;
      # needs to be 8099 when using the home assistant integration
      default = 8099;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.zigbee2mqtt = {
      owner = "zigbee2mqtt";
      restartUnits = [ "zigbee2mqtt.service" ];
      path = "${config.services.zigbee2mqtt.dataDir}/secrets.yaml";
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {
        inherit (cfg) port;
      };

      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Zigbee2MQTT";
          subtitle = "adapter";
          tag = "utility";
          keywords = "selfhosted zigbee mqtt adapter";
        };
      };
    };

    services.zigbee2mqtt = {
      enable = true;
      settings = {
        version = 5;
        mqtt = {
          base_topic = "zigbee2mqtt";
          # TODO improve this by fetching the domain + port from config / not hardcoded
          server = "!secrets.yaml server";
          user = "!secrets.yaml user";
          password = "!secrets.yaml password";
        };
        serial = {
          port = "/dev/ttyUSB0";
          adapter = "zstack";
        };
        availability = {
          enabled = true;
          active.timeout = 2;
        };
        advanced = {
          channel = 20;
          network_key = "!secrets.yaml network_key";
          ext_pan_id = [
            204
            106
            198
            183
            122
            189
            129
            232
          ];
          pan_id = 34335;
        };
        frontend = {
          enabled = true;
          package = "zigbee2mqtt-windfront";
          inherit (cfg) port;
          host = "127.0.0.1";
          url = "https://${netlib.domainFor cfg.host}";
        };
        homeassistant = {
          enabled = true;
          discovery_topic = "homeassistant";
          status_topic = "homeassistant/status";
          experimental_event_entities = false;
          legacy_action_sensor = false;
        };
      };
    };
  };
}
