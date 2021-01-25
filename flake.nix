{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:rycee/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    ## extra packages
    neovim-nightly-src = { url = "github:neovim/neovim"; flake = false; };
    # rofi source not here since rofi requires submodules which flake inputs dont support yet
    # rofi-wayland-src = { url = "github:lbonn/rofi"; flake = false; submodules = true; };
    # rofi-pass-gopass-src = { url = "github:carnager/rofi-pass/gopass"; flake = false; };
  };
  outputs = { self, nixpkgs, neovim-nightly-src, home-manager, nixos-hardware, ... }@inputs: let 
    #overlays = map 
    #(name: import (./overlays + "/${name}") { inherit inputs; })
    #(builtins.attrNames (builtins.readDir ./overlays));
    overlays = [
      (import ./overlays/nvim-overlay.nix {inherit inputs; })
      (import ./overlays/rofi-overlay.nix {inherit inputs; })
      (import ./custom_pkgs)
    ];

    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system overlays; config.allowUnfree = true; };

    # every setup is a system + a user
    # the system is mainly used for hardware config, the user for software-specific setups
    mkSetup = {name, host, username, extramods ? []}: let 
      hostmod = import (./hosts + "/${host}") { inherit pkgs username; };
      ret = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          hostmod
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${username}" = import (./users + "/${username}/home.nix") { inherit pkgs; };
          }
        ] ++ extramods;
      }; in ret;
      setup-script = pkgs.writeShellScriptBin "setup" ''
        if [[ -z "$1" || "$1" == "help" ]]; then
          echo -e "Usage: $(basename $0) {config} [ update | switch | build | install ]\n\nFor more details on the options see \`man nixos-rebuild\`"
          echo -e ""
          echo -e "Available configs:"
          echo -e "   - \"nixos-laptop\":  laptop setup for work"
        elif [[ "$1" == "update" ]]; then 
          nix flake update --recreate-lock-file --commit-lock-file
        elif [[ "$2" == "install" ]]; then
          sudo nixos-install --flake ".#$1" "${"\${@:3}"}"
        else
          sudo nixos-rebuild --flake ".#$1" "${"\${@:2}"}"
        fi
      '';
  in {
    devShell."${system}" = pkgs.mkShell {
      buildInputs = with pkgs; [
        git 
        neovim-nightly
        rofi-wayland
        git-crypt
        setup-script
      ];
    };

    nixosConfigurations.nixos-laptop = mkSetup { 
      name = "nixos-laptop";
      host = "work-laptop-thinkpad";
      #extramods = [ nixos-hardware.nixosModules.lenovo-thinkpad-t490 ];
      username = "nixos";
    };
  };
}
