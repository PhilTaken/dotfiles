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
    inputs.nur-src.overlay
    inputs.devshell.overlay
    inputs.sops-nix-src.overlay
    inputs.deploy-rs.overlay
    inputs.neovim-nightly.overlay
    inputs.polymc.overlay
    inputs.arm-rs.overlays.default
    inputs.hyprland.overlays.default
    inputs.zellij.overlays.default
    inputs.eww-git.overlays.default
    (final: prev: {
      makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });

      webcord = inputs.webcord.packages.${prev.system}.default;

      #slack = prev.slack.overrideAttrs (old: {
        #installPhase = old.installPhase + ''
          #rm $out/bin/slack

          #makeWrapper $out/lib/slack/slack $out/bin/slack \
          #--prefix XDG_DATA_DIRS : $GSETTINGS_SCHEMAS_PATH \
          #--prefix PATH : ${lib.makeBinPath [prev.xdg-utils]} \
          #--add-flags "--enable-features=WebRTCPipeWireCapturer %U"
        #'';
      #});

      inherit (inputs.nixpkgs-stable.outputs.legacyPackages.${prev.system}) gopass iosevka;
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

  extraHMImports = [
    inputs.spicetify.homeManagerModule
    inputs.hyprland.homeManagerModules.default
  ];
in
rec {
  inherit pkgs;

  user = import ./user.nix { inherit pkgs home-manager lib system overlays extraHMImports; };
  host = import ./host.nix { inherit system pkgs home-manager lib user extramodules nixpkgs inputs; };
  server = import ./server.nix { inherit pkgs host lib; };
  shells = import ./shells.nix { inherit pkgs; };
  iso = import ./iso.nix { inherit pkgs nixpkgs lib system; };
}
