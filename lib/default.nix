{ inputs
, system
, extraHMImports ? [ ]
, ...
}:

let
  inherit (inputs) home-manager nixpkgs;
  inherit (nixpkgs) lib;

  overlays = [
    (import ../custom_pkgs)
    (import ../overlays/gopass-rofi.nix { inherit inputs; })
    (import ../overlays/rofi-overlay.nix { inherit inputs; })
    (import ../overlays/eww.nix { inherit inputs; })
    inputs.nur-src.overlay
    inputs.devshell.overlay
    inputs.sops-nix-src.overlay
    inputs.deploy-rs.overlay
    inputs.neovim-nightly.overlay
    inputs.polymc.overlay
    inputs.arm-rs.overlays.default
    inputs.hyprland.overlays.default
    inputs.zellij.overlays.default
    (final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });

      inherit (inputs.nixpkgs-stable.outputs.legacyPackages.${system}) gopass iosevka;
      inherit (inputs.nixpkgs-unstable-comfy.outputs.legacyPackages.${system}) iosevka-comfy;
    })
  ];

  pkgs = import nixpkgs {
    inherit system overlays;
    config.allowUnfree = true;
  };

  extramodules = [
    inputs.arm-rs.nixosModules.default
    inputs.hyprland.nixosModules.default
    inputs.sops-nix-src.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
  ] ++ lib.optionals (system == "aarch64-linux") [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  extraHMImports = [ inputs.spicetify.homeManagerModule ];
in
rec {
  inherit pkgs;

  user = import ./user.nix { inherit pkgs home-manager lib system overlays extraHMImports; };
  host = import ./host.nix { inherit system pkgs home-manager lib user extramodules nixpkgs; };
  server = import ./server.nix { inherit pkgs host lib; };
  shells = import ./shells.nix { inherit pkgs; };
  iso = import ./iso.nix { inherit pkgs nixpkgs lib system; };
}
