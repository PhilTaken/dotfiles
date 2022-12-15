{ inputs
, extraHMImports ? [ ]
, self
, ...
}:
system:

let
  inherit (inputs) home-manager nixpkgs;
  inherit (nixpkgs) lib;

  overlays = [
    inputs.nur-src.overlay
    inputs.devshell.overlay
    inputs.sops-nix-src.overlay
    inputs.deploy-rs.overlay
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

      # add webgpu backend dependencies for wezterm
      #wezterm = prev.wezterm.overrideAttrs (old: {
        #nativeBuildInputs = old.nativeBuildInputs ++ [ prev.makeWrapper ];

        #postInstall = old.postInstall + ''
          #wrapProgram "$out/bin/wezterm" --prefix LD_LIBRARY_PATH : "${prev.lib.makeLibraryPath [ prev.vulkan-loader ]}"
        #'';
      #});

    } // (prev.lib.mapAttrs
      (n: _: prev.callPackage (../. + "/custom_pkgs/${n}") { inherit inputs; })
      (prev.lib.filterAttrs
        (_: v: v == "directory")
        (builtins.readDir ../custom_pkgs))))
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
  overlay = final: prev: prev.lib.foldl' lib.mergeAttrs { } (map (o: o final prev) overlays);

  user = import ./user.nix { inherit pkgs home-manager lib system overlays extraHMImports inputs; };
  host = import ./host.nix { inherit system pkgs home-manager lib user extramodules nixpkgs inputs; };
  server = import ./server.nix { inherit pkgs host lib; };
  shells = import ./shells.nix { inherit pkgs lib; };
  iso = import ./iso.nix { inherit pkgs nixpkgs lib system; };
}
