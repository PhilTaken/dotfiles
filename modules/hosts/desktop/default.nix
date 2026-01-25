{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.desktop;

  orca-slicer-wrapped = pkgs.symlinkJoin {
    name = "orca-slicer-wrapped";
    paths = [ pkgs.orca-slicer ];
    buildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      wrapProgram $out/bin/orca-slicer \
        --prefix __EGL_VENDOR_LIBRARY_FILENAMES : ${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json
    '';

  };
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

    services.flatpak.enable = true;

    hardware.graphics.enable = true;
    #virtualisation.waydroid.enable = true;
    virtualisation.docker.enable = false;

    # qmk rules for flashing keebs
    services.udev.packages = with pkgs; [ qmk-udev-rules ];

    nixpkgs.config.permittedInsecurePackages = [
      # permit old mbedtls for lutris
      "mbedtls-2.28.10"
    ];

    programs.appimage = {
      enable = true;
      binfmt = true;
      package = pkgs.appimage-run.override {
        extraPkgs = pkgs: [ pkgs.webkitgtk_4_1 ];
      };
    };

    environment.systemPackages = with pkgs; [
      #calibre
      vlc
      foliate
      pdfsam-basic
      xournalpp

      # 3d printing
      freecad
      openscad-unstable

      orca-slicer-wrapped

      # (pkgs.callPackage ./orca-slicer.nix {})

      # notes
      obsidian

      zen-browser

      lutris

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
      tauon

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
