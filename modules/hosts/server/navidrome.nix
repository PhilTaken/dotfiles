{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.navidrome;
in
{
  options.phil.navidrome = {
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
      default = "/media/music";
    };

    data_folder = mkOption {
      type = types.str;
      default = "/media/navidrome";
    };
  };

  config = mkIf (cfg.enable) {
    services.navidrome = {
      enable = true;
      settings = {
        Port = cfg.port;
        MusicFolder = cfg.music_folder;
        DataFolder = cfg.data_folder;
      };
    };
  };
}

