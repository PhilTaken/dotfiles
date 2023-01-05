{ inputs }:
let
  systemmodules = rec {
    default = [
      inputs.arm-rs.nixosModules.default
      inputs.hyprland.nixosModules.default
      inputs.sops-nix-src.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager
    ];
    "aarch64-linux" = default ++ [
      "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
      inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ];
  };

  overlays = [
    inputs.nur-src.overlay
    inputs.neovim-nightly.overlay
    inputs.arm-rs.overlays.default
    inputs.hyprland.overlays.default
    inputs.parinfer-rust.overlays.default
    #inputs.zellij.overlays.default
    inputs.eww-git.overlays.default
    inputs.nil-ls.overlays.default
    inputs.vim-extra-plugins.overlays.default

    (final: prev: {
      makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });

      webcord = inputs.webcord.packages.${prev.system}.default;
      hyprland = inputs.hyprland.packages.${prev.system}.default;
      #inherit (inputs.nixpkgs-stable.outputs.legacyPackages.${prev.system}) gopass iosevka;

      # devdocs.io
      devdocs-desktop = prev.writeShellApplication {
        name = "devdocs";
        text = "${prev.devdocs-desktop}/bin/devdocs-desktop --no-sandbox";
      };

      # fix it on wayland
      prismlauncher = prev.prismlauncher.overrideAttrs (old: {
        postInstall = old.postInstall + ''
          wrapProgram $out/bin/prismlauncher \
            --prefix QT_QPA_PLATFORM : xcb
        '';
      });
    } // (prev.lib.mapAttrs
      (n: _: prev.callPackage (../. + "/custom_pkgs/${n}") { inherit inputs; })
      (prev.lib.filterAttrs
        (_: v: v == "directory")
        (builtins.readDir ../custom_pkgs))))
  ];
in rec {
  pkgsFor = system: import inputs.nixpkgs {
    inherit overlays system;
    config.allowUnfree = true;
  };

  iso = import ./iso.nix;
  user = import ./user.nix { inherit inputs; };
  host = import ./host.nix { inherit user inputs pkgsFor systemmodules; };
  server = import ./server.nix { inherit host inputs; };
}
