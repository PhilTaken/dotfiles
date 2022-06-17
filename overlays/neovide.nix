{ inputs
, ...
}:
final: prev:
let
  neovide = prev.neovide.overrideAttrs (old: rec {
    version = "git";
    src = inputs.neovide-src;
    cargoDeps = old.cargoDeps.overrideAttrs (_: {
      inherit src;
      name = "neovide-vendor.tar.gz";
      outputHash = "sha256-QuGMKAaIx00Hg9AEohx0vbju2+hTdHCnXgOV1unOqDE=";
    });
  });
in
{ inherit neovide; }
