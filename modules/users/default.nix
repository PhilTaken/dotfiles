{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./terminals
    ./shells
    ./tmux
    ./zellij
    ./editors

    ./git
    ./ssh
    ./gpg

    ./mail
    ./music
    ./browsers

    ./wms
    ./des

    ./work
  ];

  config = {
    xdg.configFile."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
    home.sessionVariables.NIX_PATH = "nixpkgs=${config.xdg.configHome}/nix/inputs/nixpkgs$\{NIX_PATH:+:$NIX_PATH}";

    nix.registry.nixpkgs.flake = inputs.nixpkgs;

    home.packages = with pkgs; [
      cacert
      coreutils
      hicolor-icon-theme
      qt5.qtbase
      weather-icons

      #magic-wormhole
      cachix
      gping
      hyperfine
      #texlive.combined.scheme-medium
      tokei
      #vpnc
      wget
      youtube-dl

      #obsidian
      anki
      element-desktop
      #gimp
      #keepassxc

      libreoffice
      #signal-desktop
      tdesktop
    ];
  };
}
