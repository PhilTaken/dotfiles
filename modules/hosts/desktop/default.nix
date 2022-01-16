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

        libbluray = pkgs.libbluray.override {
          withAACS = true;
          withBDplus = true;
        };
        vlc = pkgs.vlc.override { inherit libbluray; };
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
        gnucash
      ];
  };
}

