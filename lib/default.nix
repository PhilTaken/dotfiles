{
  self,
  inputs,
}: let
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

    inputs.lix-module.overlays.default

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
    inherit user inputs pkgsFor;
    flake = self;
  };
  server = import ./server.nix {inherit host inputs;};
}
