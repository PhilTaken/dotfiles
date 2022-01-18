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
      in
      with pkgs; [
        #vscodium-with-extensions
        vscodium
        vlc
        audacity
        handbrake
        makemkv
        obs-studio
        google-chrome
        ungoogled-chromium

        #uget
        #uget-integrator

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

