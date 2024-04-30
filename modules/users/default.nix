{
  config,
  inputs,
  pkgs,
  lib,
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
    ./leisure
  ];

  options = {
    phil.headless = lib.mkEnableOption "headless user account -> no graphical applications";
  };

  config = {
    xdg.configFile."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
    home.sessionVariables.NIX_PATH = "nixpkgs=${config.xdg.configHome}/nix/inputs/nixpkgs$\{NIX_PATH:+:$NIX_PATH}";

    nix.registry.nixpkgs.flake = inputs.nixpkgs;

    home.packages = with pkgs;
      [
        cacert
        coreutils

        cachix
        gping
        hyperfine
        tokei
        wget
      ]
      ++ (lib.optionals (!config.phil.headless) [
        hicolor-icon-theme
        weather-icons
      ]);
  };
}
