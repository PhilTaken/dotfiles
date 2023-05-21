{
  config,
  inputs,
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
  };
}
