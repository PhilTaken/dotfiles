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
      default = true;
    };

    enableMpris = mkEnableOption "mpris";

    spotifyd_devicename = mkOption {
      description = "spotifyd device name";
      type = types.str;
      default = "maelstroem";
    };

    spotifyd_username = mkOption {
      description = "spotifyd username";
      type = types.str;
      default = "wtfusername?";
    };
  };

  config = (mkIf cfg.enable) {
    xdg.configFile."spotifyd/credentials".source = config.lib.file.mkOutOfStoreSymlink "/run/secrets/spotify-password";

    services.spotifyd = {
      enable = true;
      package = pkgs.spotifyd.override {
        withKeyring = true;
        withPulseAudio = true;
        withMpris = true;
      };
      settings = {
        global = {
          username = "${cfg.spotifyd_username}";
          password_cmd = "${pkgs.coreutils}/bin/cat ${config.xdg.configHome}/spotifyd/credentials";
          backend = "pulseaudio";
          #device = "default";
          bitrate = 320;
          volume_normalization = false;
          device_type = "computer";
          no_audio_cache = true;
          cache_path = "/tmp/spotifyd";
          autoplay = true;
          use_mpris = true;
          dbus_type = "system";
        };
      };
    };

    systemd.user.services.mpris-proxy = mkIf cfg.enableMpris {
      Unit.Description = "Mpris proxy";
      Unit.After = [ "network.target" "sound.target" ];
      Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
      Install.WantedBy = [ "default.target" ];
    };

    programs.spicetify = {
      enable = true;
      theme = "catppuccin-mocha";
      colorScheme = "flamingo";

      enabledExtensions = [
        "fullAppDisplay.js"
        "shuffle+.js"
        "hidePodcasts.js"
      ];
    };

    services.easyeffects.enable = true;

    home.packages = with pkgs; [
      #spotify-unwrapped
      #spotify

      ffmpeg
      playerctl
      pamixer
      pavucontrol
      mpv
    ];
  };
}
