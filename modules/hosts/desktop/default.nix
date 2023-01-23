{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.desktop;
in
{
  options.phil.desktop = {
    enable = mkOption {
      description = "enable desktop module";
      type = types.bool;
      default = false;
    };

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
      #audacity
      #obs-studio
      #handbrake
      #makemkv

      # games
      prismlauncher
      citra
      yuzu-ea
      osu-lazer

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
      (nur.repos.shados.tmm.overrideAttrs (old: rec {
        version = "4.3.8";
        src = builtins.fetchurl {
          url = "https://release.tinymediamanager.org/v4/dist/tmm_${version}_linux-amd64.tar.gz";
          sha256 = "187q3lz7mrvqasi9qn4rva6dfq04w360drqikwcr5i9rzir2mc0z";
        };
      }))

      # typey-typey
      plover.dev
    ];
  };
}

