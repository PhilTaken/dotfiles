{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    neovim-nightly-src = { url = "github:neovim/neovim"; flake = false; };
    # rofi-lbonn-src = { url = "github:lbonn/rofi"; flake = false; recursive = true; };
    home-manager = { 
      url = "github:rycee/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, neovim-nightly-src, home-manager, ... }@inputs: let 
    overlays = [
      (import ./overlays/nvim-overlay.nix { inherit neovim-nightly-src; })
      (import ./overlays/rofi-overlay.nix {  })
    ];
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };
  in {
    devShell."${system}" = pkgs.mkShell {
      buildInputs = with pkgs; [
        neovim
        rofi
      ];
    };

    homeConfigurations = {
      laptop = inputs.home-manager.lib.homeManagerConfiguration {
        configuration = import ./home.nix { inherit pkgs; };
        inherit system;
        homeDirectory = "/home/nixos";
        username = "nixos";
      };
    };
    laptop = self.homeConfigurations.laptop.activationPackage;
  };
}
