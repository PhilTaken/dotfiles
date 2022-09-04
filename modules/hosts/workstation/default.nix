{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.workstation;
in
{
  options.phil.workstation = {
    enable = mkOption {
      description = "enable workstation module";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    programs.steam.enable = true;
    programs.gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          renice = 10;
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };

    hardware.opengl.enable = true;

    # antivir daemon
    #services.clamav = {
    #daemon.enable = true;
    #updater.enable = true;
    #};

    #virtualisation.waydroid.enable = true;

    # qmk rules for flashing keebs
    services.udev.packages = with pkgs; [ qmk-udev-rules ];

    environment.systemPackages =
      let
        extensions = with pkgs.vscode-extensions; [
          bbenoist.nix
          #ms-python.python
          ms-toolsai.jupyter
        ];

        vscodium-with-extensions = pkgs.vscode-with-extensions.override {
          vscode = pkgs.vscodium;
          vscodeExtensions = extensions;
        };

      in
      with pkgs; [
        #vscodium-with-extensions
        vscodium

        beets

        vlc
        calibre
        foliate
        pdfsam-basic
        xournalpp
        baobab
        xfce.thunar

        # audio/video
        audacity
        obs-studio
        #handbrake
        #makemkv

        # games
        #polymc
        #citra
        #yuzu-ea
        osu-lazer

        # downloads
        #uget
        #uget-integrator
        #qbittorrent

        #skrooge
        #waydroid

        deploy-rs.deploy-rs
      ];
  };
}

