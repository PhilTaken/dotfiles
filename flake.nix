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
    overlays = [
      (import ./overlays/nvim-overlay.nix { inherit inputs; })
      (import ./overlays/rofi-overlay.nix {  })
    ];

    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system overlays; config.allowUnfree = true; };
  in {
    devShell."${system}" = pkgs.mkShell {
      # add script for easy deployment
    };

    # add more configs
    nixosConfigurations.nixos-laptop = nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [ 
        ./configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.nixos = import profiles/nixos { inherit pkgs; };
        }
      ];
    };
  };
}
