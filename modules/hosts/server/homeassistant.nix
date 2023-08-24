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
      default = "homeassistant";
    };

    port = mkOption {
      type = types.port;
      default = 3201;
    };
  };

  config = mkIf cfg.enable {
    services.home-assistant = {
      inherit (cfg) enable;
      extraComponents = [
        "esphome"
        "met"
        "radio_browser"
      ];

      config = {
        default_config = {};
      };
    };
  };
}
