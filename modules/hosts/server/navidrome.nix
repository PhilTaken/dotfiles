{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.navidrome;
in
{
  options.phil.server.services.navidrome = {
    enable = mkEnableOption "navidrome";
    host = mkOption {
      type = types.str;
      default = "navidrome";
    };

    port = mkOption {
      type = types.port;
      default = 4533;
    };

    music_folder = mkOption {
      type = types.str;
      default = "/media/Music";
    };
  };

  config = mkIf cfg.enable {
    services.navidrome = {
      enable = true;
      settings = {
        Port = cfg.port;
        MusicFolder = cfg.music_folder;
      };
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = { inherit (cfg) port; };
      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Navidrome";
          subtitle = "Music Server";
          tag = "app";
          keywords = "selfhosted music";
          logo = "https://raw.githubusercontent.com/navidrome/navidrome/master/resources/logo-192x192.png";
        };
      };
    };
  };
}

