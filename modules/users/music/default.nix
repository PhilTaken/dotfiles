{ pkgs
, config
, lib
, inputs
, ...
}:
with lib;

let
  cfg = config.phil.music;
in
{
  imports = [
    inputs.spicetify.homeManagerModule
  ];

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
        withMpris = cfg.enableMpris;
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

    programs.spicetify =
      let
        spicePkgs = inputs.spicetify.packages.${pkgs.system}.default;
      in
      {
        enable = true;
        theme = spicePkgs.themes.catppuccin-mocha;
        colorScheme = "flamingo";

        enabledExtensions = with spicePkgs.extensions; [
          fullAppDisplay
          shuffle
          hidePodcasts
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
      downonspot
    ];

    programs.beets = {
      enable = true;
      settings = {
        plugins = [
          "fetchart"
          "convert"
          "scrub"
          "replaygain"
          "lastgenre"
          "chroma"
          "web"
          "spotify"
          "lastimport"
          "acousticbrainz"
          "badfiles"
        ];

        art_filename = "albumart";
        threaded = true;
        original_date = false;
        per_disc_numbering = false;
        convert.auto = false;
        directory = "/mnt/media/Music";

        import = {
          write = true;
          copy = false;
          move = true;
          resume = "ask";
          incremental = true;
          quiet_fallback = "skip";
          timid = false;
        };

        fetchart = {
          cautious = true;
          cover_names = "front back";
          sources = [
            "filesystem"
            { coverart = "release"; }
            "itunes"
            { coverart = "releasegroup"; }
            "lastfm"
            "*"
          ];
        };

        badfiles = {
          check_on_import = true;
        };
      };
    };
  };
}
