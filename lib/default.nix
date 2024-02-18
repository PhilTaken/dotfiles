{
  self,
  inputs,
}: let
  systemmodules = rec {
    default = [
      #inputs.arm-rs.nixosModules.default
      inputs.sops-nix-src.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager
      inputs.hyprland.nixosModules.default
      inputs.disko.nixosModules.disko
    ];
    #"aarch64-linux" =
    #default
    #++ [
    #"${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
    #inputs.nixos-hardware.nixosModules.raspberry-pi-4
    #];
  };

  overlays = [
    inputs.nur-src.overlay
    #inputs.neovim-nightly-overlay.overlay
    #inputs.arm-rs.overlays.default
    inputs.hyprland.overlays.default
    inputs.parinfer-rust.overlays.default
    #inputs.zellij.overlays.default
    #inputs.eww-git.overlays.default
    inputs.nil-ls.overlays.default
    inputs.nixneovimplugins.overlays.default
    inputs.xdg-desktop-hyprland.overlays.default

    self.overlays.default

    (
      _final: prev: {
        makeModulesClosure = x: prev.makeModulesClosure (x // {allowMissing = true;});

        inherit (inputs.eww-git.packages.${prev.system}) eww eww-wayland;

        webcord = inputs.webcord.packages.${prev.system}.default;
        hyprland = inputs.hyprland.packages.${prev.system}.default;

        # devdocs.io
        devdocs-desktop = prev.writeShellApplication {
          name = "devdocs";
          text = "${prev.devdocs-desktop}/bin/devdocs-desktop --no-sandbox";
        };

        zjstatus = inputs.zjstatus.packages.${prev.system}.default;

        # fix it on wayland
        prismlauncher = prev.prismlauncher.overrideAttrs (old: {
          postInstall =
            (old.postInstall or "")
            + ''
              wrapProgram $out/bin/prismlauncher \
                --prefix QT_QPA_PLATFORM : xcb
            '';
        });

        downonspot = prev.downonspot.overrideAttrs (_oldAttrs: {
          version = "latest";
          src = (import ../npins).DownOnSpot;

          postPatch = ''
            cp ${./downonspot.cargo.lock} Cargo.lock
            cp ${./downonspot.cargo.toml} Cargo.toml
          '';

          cargoDeps = prev.rustPlatform.importCargoLock {
            lockFile = ./downonspot.cargo.lock;
          };
        });
      }
    )
  ];
in rec {
  pkgsFor = system:
    import inputs.nixpkgs {
      inherit overlays system;
      config.allowUnfree = true;
      # https://github.com/NixOS/nixpkgs/issues/269713
      config.permittedInsecurePackages = [
        "openssl-1.1.1w"
      ];
    };

  iso = import ./iso.nix {inherit inputs;};
  user = import ./user.nix {inherit inputs;};
  host = import ./host.nix {
    inherit user inputs pkgsFor systemmodules;
    flake = self;
  };
  server = import ./server.nix {inherit host inputs;};
}
