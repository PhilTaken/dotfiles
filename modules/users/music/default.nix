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
      description = "Enable the music module";
      type = types.bool;
      default = false;
    };
  };

  config = (mkIf cfg.enable) {

    programs.spicetify = {
      enable = true;
      theme = "Onepunch";
      #colorScheme = "Nord-Dark";
      #enabledCustomApps = ["reddit"];
      #enabledExtensions = ["newRelease.js"];
    };

    home.packages = with pkgs; [
      #spotify-unwrapped

      ffmpeg
      playerctl
      pamixer
      pavucontrol
      mpv
    ];
  };
}
