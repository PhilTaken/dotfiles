{ pkgs
, config
, lib
, inputs
, ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.desktop;
in
{
  options.phil.desktop = {
    enable = mkEnableOption "desktop";
    # more options
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;
    programs.gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          renice = 15;
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };

    hardware.opengl.enable = true;
    #virtualisation.waydroid.enable = true;
    virtualisation.docker.enable = true;

    # qmk rules for flashing keebs
    services.udev.packages = with pkgs; [ qmk-udev-rules ];

    environment.systemPackages = with pkgs; [
      # audio/video
      audacity
      obs-studio
      handbrake
      makemkv

      # games
      prismlauncher
      #citra
      #sergviceyuzu-ea
      #osu-lazer

      # downloads
      #uget
      #uget-integrator
      #qbittorrent
      nicotine-plus

      #skrooge
      #waydroid

      # e-guitar stuff
      guitarix
      qjackctl
      jack2

      # tiny media manager
      (nur.repos.shados.tmm.overrideAttrs (old: {
        version = "latest";
        src = inputs.tmm-src;
      }))

      # typey-typey
      plover.dev
    ];
  };
}

