{
  self,
  inputs,
}: let
  overlays = [
    inputs.nur-src.overlays.default

    #inputs.arm-rs.overlays.default

    inputs.parinfer-rust.overlays.default
    inputs.nil-ls.overlays.default
    inputs.nixneovimplugins.overlays.default

    self.overlays.default

    (_final: prev: {
      makeModulesClosure = x: prev.makeModulesClosure (x // {allowMissing = true;});

      zen-browser = inputs.zen-browser.packages.${prev.system}.default; # beta
      nixVersions =
        prev.nixVersions
        // {
          nix_2_18 = prev.lix;
        };

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
    })
  ];
in rec {
  user = import ./user.nix {inherit inputs;};
  host = import ./host.nix {
    inherit user inputs overlays;
    flake = self;
  };
  server = import ./server.nix {inherit host inputs;};
}
