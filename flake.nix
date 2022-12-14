{
  inputs = {
    # -----------------------
    # package repositories

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-22.05";

    # NUR
    nur-src.url = "github:nix-community/NUR";

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    vim-extra-plugins.url = "github:m15a/nixpkgs-vim-extra-plugins?ref=3e08bbd37dc9bec38d9a4d8597a90d80372b47af";

    # -----------------------
    # flake utilities

    flake-parts.url = "github:hercules-ci/flake-parts";

    # devshell for some nice menu + easy command adding capabilities
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # -----------------------
    # nixos modules

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # local user package managment
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # for secret managment
    sops-nix-src = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # -----------------------
    # single applications/services

    spicetify.url = "github:the-argus/spicetify-nix";

    # TODO: once my prs are merged revert to main repo
    #eww-git.url = "github:elkowar/eww?ref=7623e7e692042f4da8525bb1e4ef140831fcdb6a";
    eww-git.url = "github:PhilTaken/eww?ref=7837576ee0d2b5ba93b7c9bace0a66338897f5ef";

    # better discord clone/fork
    webcord.url = "github:fufexan/webcord-flake";

    # best nix language server
    nil-ls.url = "github:oxalica/nil";

    # deploy remote setups
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      #url = "/home/maelstroem/Documents/syncthing/work/serokell/deploy-rs/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly = {
      url = "github:neovim/neovim?dir=contrib";
      #url = "github:andersevenrud/neovim?dir=contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:vaxerski/Hyprland";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    #zellij = {
    #url = "github:zellij-org/zellij";
    #inputs.nixpkgs.follows = "nixpkgs";
    #};

    arm-rs = {
      url = "github:PhilTaken/arm.rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";

    parinfer-rust.url = "github:PhilTaken/parinfer-rust";
  };

  outputs = { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];

      imports = [
        ./modules/flake/configurations.nix
        ./modules/flake/modules.nix
        ./modules/flake/deploy.nix
        ./modules/flake/shells.nix
      ];
    };
}
