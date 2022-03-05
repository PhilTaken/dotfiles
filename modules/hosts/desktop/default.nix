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

  config = mkIf (cfg.enable) {
    programs.steam.enable = true;

    hardware.opengl.enable = true;

    # antivir daemon
    services.clamav = {
      daemon.enable = true;
      updater.enable = true;
    };

    virtualisation.waydroid.enable = true;

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

        yuzu-ea-latest = (pkgs.yuzu-ea.override rec {
          version = "2496";
          src = pkgs.fetchFromGitHub {
            owner = "pineappleEA";
            repo = "pineapple-src";
            rev = "EA-${version}";
            sha256 = "sha256-jk265xoGW+V6wLyJj7BDNBEUSg3LLZqIMVLjdnAeBOc=";
          };
        });
      in
      with pkgs; [
        #vscodium-with-extensions
        vscodium
        vlc
        audacity
        handbrake
        makemkv
        obs-studio
        citra
        polymc
        yuzu-ea-latest

        #chromium
        google-chrome
        nyxt

        uget
        uget-integrator

        skrooge
        yt-dlp

        qbittorrent
        pdfsam-basic
        foliate
        xournalpp
        baobab
        waydroid
        beets
      ];
  };
}

