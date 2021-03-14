{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:rycee/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    ## extra packages
    neovim-nightly-src = { url = "github:neovim/neovim"; flake = false; };

    # rofi source not here since rofi requires submodules which flake inputs dont support yet
    # rofi-wayland-src = { url = "github:lbonn/rofi"; flake = false; submodules = true; };
    # rofi-pass-gopass-src = { url = "github:carnager/rofi-pass/gopass"; flake = false; };
  };
  outputs = { self, nixpkgs, neovim-nightly-src, home-manager, nixos-hardware, deploy-rs, ... }@inputs: let #overlays = map
    system = "x86_64-linux";
    overlays = [
      (import ./overlays/nvim-overlay.nix {inherit inputs; })
      (import ./overlays/rofi-overlay.nix {inherit inputs; })
      (import ./overlays/gopass-rofi.nix { inherit inputs; })
      (import ./custom_pkgs)
    ];

    pkgs = import nixpkgs { inherit system overlays; config.allowUnfree = true; };

    # every setup is a system + a user
    # the system is mainly used for hardware config, the user for software-specific setups

    mkRemoteSetup = {host, username ? "nixos", extramods ? []}: let
      hostmod = import (./hosts + "/${host}") { inherit inputs pkgs username; };
    in nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [ hostmod ] ++ extramods;
    };

    mkLocalSetup = {host, username, extramods ? []}: let
      hostmod = import (./hosts + "/${host}") { inherit inputs pkgs username; };
      usermods = [
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${username}" = import (./users + "/${username}/home.nix") { inherit pkgs username; };
        }
      ] ++ extramods;
    in mkRemoteSetup {
      inherit host username;
      extramods = usermods;
    };

    setup-script = pkgs.writeShellScriptBin "setup" ''
        if [[ -z "$1" || "$1" == "help" ]]; then
          echo -e "Usage: $(basename $0) {config} [ update | switch | build | install ]\n\nFor more details on the options see \`man nixos-rebuild\`"
          echo -e ""
          echo -e "Available configs:"
          echo -e "   - \"nixos-laptop\":  laptop setup for work"
        elif [[ "$1" == "update" ]]; then
          nix flake update --commit-lock-file
        elif [[ "$2" == "install" ]]; then
          sudo nixos-install --flake ".#$1" "${"\${@:3}"}"
        elif [[ "$2" == "upgrade" ]]; then
          nix flake update --commit-lock-file && sudo nixos-rebuild --flake ".#$1" switch
        else
          sudo nixos-rebuild --flake ".#$1" "${"\${@:2}"}"
        fi
    '';
  in {
    devShell."${system}" = pkgs.mkShell {
      buildInputs = with pkgs; [
        git
        git-crypt
        setup-script
        deploy-rs.packages."${system}".deploy-rs
      ];
    };

    # workplace-issued thinkpad
    nixosConfigurations.nixos-laptop = mkLocalSetup {
      host = "work-laptop-thinkpad";
      username = "nixos";
    };

    # vm on a hetzner server, debian host
    nixosConfigurations.alpha = mkRemoteSetup {
      host = "alpha";
    };

    # deploy config
    deploy.nodes = {
      alpha = {
        hostname = "148.251.102.93";
        sshUser = "root";
        profiles.system.path = deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations.alpha;
      };
    };

    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
