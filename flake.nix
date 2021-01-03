{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:rycee/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-src = { url = "github:neovim/neovim"; flake = false; };
    # rofi-lbonn-src = { url = "github:lbonn/rofi"; flake = false; recursive = true; };
  };
  outputs = { self, nixpkgs, neovim-nightly-src, home-manager, ... }@inputs: let 
    #overlays = [
    #  (import ./overlays/nvim-overlay.nix { inherit inputs; })
    #  (import ./overlays/rofi-overlay.nix { inherit inputs; })
    #];
    overlays = map 
    (name: import (./overlays + "/${name}") { inherit inputs; })
    (builtins.attrNames (builtins.readDir ./overlays));

    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system overlays; config.allowUnfree = true; };

    mkSetup = {name, host, username}: let 
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
        ];
      }; in ret;
      setup-script = pkgs.writeShellScriptBin "setup" ''
        if [[ -z "$1" || "$1" == "help" ]]; then
          echo -e "Usage: $(basename $0) {config} [ update | switch | build | install ]\n\nFor more details on the options see \`man nixos-rebuild\`"
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
        neovim
        rofi
        git-crypt
        setup-script
      ];
    };

    nixosConfigurations.nixos-laptop = mkSetup { 
      name = "nixos-laptop";
      host = "work-laptop-thinkpad";
      username = "nixos";
    };
  };
}
