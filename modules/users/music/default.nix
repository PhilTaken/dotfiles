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
  };

  config = (mkIf cfg.enable) {

    home.packages = with pkgs; [
      spotify-unwrapped

      ffmpeg
      playerctl
      pamixer
      pavucontrol
      mpv
    ];
  };
}
