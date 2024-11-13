{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.music;
in {
  imports = [
    inputs.spicetify.homeManagerModules.default
    #./autoeq-easyeffects.nix
  ];

  options.phil.music = {
    enable = mkEnableOption "music";
    enableMpris = mkOption {
      description = "mpris";
      type = types.bool;
      default = true;
    };

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
    # TODO: sops-nix home-manager module
    xdg.configFile."spotifyd/credentials".source = config.lib.file.mkOutOfStoreSymlink "/run/secrets/spotify-password";

    services.spotifyd = {
      # build breaks on arm currently
      enable = lib.hasInfix pkgs.system "x86";
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
          bitrate = 160;
          volume_normalization = false;
          device_type = "computer";
          no_audio_cache = false;
          cache_path = "/tmp/spotifyd";

          autoplay = true;
          use_mpris = true;
          #device = "default";
          #dbus_type = "system";
        };
      };
    };

    systemd.user.services.mpris-proxy = mkIf cfg.enableMpris {
      Unit.Description = "Mpris proxy";
      Unit.After = ["network.target" "sound.target"];
      Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
      Install.WantedBy = ["default.target"];
    };

    programs.spicetify = let
      spicePkgs = inputs.spicetify.legacyPackages.${pkgs.system};
    in {
      enable = true;
      # theme = spicePkgs.themes.catppuccin;
      # colorScheme = "mocha";

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        shuffle
        hidePodcasts
      ];
    };

    services.easyeffects = {
      enable = true;
      #presets = [
      #"TFZ Queen"
      #];
    };

    home.packages = with pkgs; [
      #spotify-unwrapped
      #spotify

      ffmpeg
      playerctl
      pamixer
      pavucontrol
      mpv
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
          "badfiles"
        ];

        art_filename = "albumart";
        threaded = true;
        original_date = false;
        per_disc_numbering = false;
        convert.auto = false;

        # https://beets.readthedocs.io/en/v1.6.0/faq.html#point-beets-at-a-new-music-directory
        directory = "/media/delta/Music";

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
            {coverart = "release";}
            "itunes"
            {coverart = "releasegroup";}
            "lastfm"
            "*"
          ];
        };

        badfiles.commands = {
          ogg = "${pkgs.liboggz}/bin/oggz-validate";
          flac = "${pkgs.flac}/bin/flac --test --warnings-as-errors --silent";
        };

        replaygain = {
          command = "${pkgs.aacgain}/bin/aacgain";
        };
      };
    };
  };
}
