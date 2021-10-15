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

    spotifyd_device_name = mkOption {
      description = "Device name for spotifyd";
      type = types.str;
      default = "phil";
    };
  };

  config = (mkIf cfg.enable) {

    # TODO move to system module "sound"
    #services.spotifyd = {
    #enable = true;
    #settings = {
    #global = {
    #device_name = cfg.spotifyd_device_name;
    #username = config.sops.secrets.spotify-username.path;
    #password = config.sops.secrets.spotify-password.path;
    #bitrate = 320;
    #no_audio_cache = true;
    #volume_normalization = false;
    #device_type = "speaker";
    #};
    #};
    #};

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
