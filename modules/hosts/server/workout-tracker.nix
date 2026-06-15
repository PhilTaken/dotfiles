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
  cfg = config.phil.server.services.workout-tracker;
in
{
  options.phil.server.services.workout-tracker = {
    enable = mkEnableOption "workout-tracker";
    url = mkOption {
      description = "workout-tracker url";
      default = "https://${netlib.domainFor cfg.host}";
      type = types.str;
    };
    port = mkOption {
      description = "port for the http interface";
      type = types.port;
      default = netlib.portFor cfg.host;
    };
    host = mkOption {
      type = types.str;
      default = "wt";
    };
  };

  config = mkIf cfg.enable {
    services.workout-tracker = {
      inherit (cfg) enable port;

      settings = {
        WT_DATABASE_DRIVER = "sqlite";
        WT_DEBUG = "false";
        WT_DSN = "./database.db";
        WT_LOGGING = "true";
      };
    };

    systemd.services.workout-tracker.serviceConfig.ReadWritePaths = [
      "/media/syncthing/data/OpenTracks/"
    ];

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {
        inherit (cfg) port;
        public = false;
      };

      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "workout-tracker";
          subtitle = "workout tracker";
          tag = "app";
          keywords = "selfhosted workout tracker";
        };
      };
    };
  };
}
