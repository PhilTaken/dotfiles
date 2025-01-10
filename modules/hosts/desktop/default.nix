{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.desktop;
in {
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

    hardware.graphics.enable = true;
    #virtualisation.waydroid.enable = true;
    virtualisation.docker.enable = true;

    # qmk rules for flashing keebs
    services.udev.packages = with pkgs; [qmk-udev-rules];

    environment.systemPackages = with pkgs; [
      #calibre
      vlc
      foliate
      pdfsam-basic
      xournalpp

      # notes
      obsidian

      zen-browser

      # e-guitar stuff
      guitarix
      qjackctl
      jack2

      # audio/video
      audacity
      ardour
      picard
      #obs-studio
      handbrake
      #makemkv

      # games
      prismlauncher
      #citra
      #yuzu-ea
      #osu-lazer

      # downloads
      #uget
      #uget-integrator
      #qbittorrent
      nicotine-plus

      #skrooge
      #waydroid

      # typey-typey
      plover.dev
    ];
  };
}
