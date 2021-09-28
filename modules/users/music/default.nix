{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.music;
in
{
  options.phil.music = {
    enable = mkOption {
      description = "Enable i3";
      type = types.bool;
      default = false;
    };

    device_name = mkOption {
      description = "Device name for spotifyd";
      type = types.str;
      default = "phil";
    };
  };

  config = (mkIf cfg.enable) {
    services.spotifyd = {
      enable = true;
      settings = (import ../../users/secret/spotify.nix {
        device_name = username;
      });
    };

    home.packages = with pkgs; [
      spotify-unwrapped

      ffmpeg
      playerctl
      pamixer
      vlc
      pavucontrol
      mpv

      #tauon
    ];
  };
}
