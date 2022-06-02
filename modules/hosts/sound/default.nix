{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.sound;
in
{
  options.phil.sound = {
    enable = mkOption {
      description = "enable the sound module";
      type = types.bool;
      default = false;
    };

    #spotifyd_devicename = mkOption {
      #description = "spotifyd device name";
      #type = types.str;
      #default = "maelstroem";
    #};

    #spotifyd_username = mkOption {
      #description = "spotifyd username";
      #type = types.str;
      #default = "wtfusername?";
    #};
  };

  config = mkIf (cfg.enable) {
    #sops.secrets.spotify-username = { };
    #sops.secrets.spotify-password = {
      #group = "audio";
      #mode = "0440";
    #};

    # Enable sound.
    sound.enable = true;
    sound.mediaKeys.enable = true;
    hardware.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    #services.spotifyd = {
      #enable = false;
      #settings = {
        #global = {
          #username = "${cfg.spotifyd_username}";
          #password_cmd = "${pkgs.coreutils}/bin/cat ${config.sops.secrets.spotify-password.path}";
          #backend = "pulseaudio";
          #bitrate = 320;
          #volume_normalization = false;
          #device_type = "speaker";
          #no_audio_cache = true;
          #cache_path = "/tmp/spotifyd";
        #};
      #};
    #};

    xdg = {
      portal = {
        enable = true;
        wlr = {
          enable = true;
          #settings = {
            #screencast = {
              #output_name = "HDMI-A-1";
              #max_fps = 30;
              #exec_before = "disable_notifications.sh";
              #exec_after = "enable_notifications.sh";
              #chooser_type = "simple";
              #chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
            #};
          #};
        };
        gtkUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
      };
    };
  };
}

