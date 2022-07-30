{ inputs, ... }:
final: prev:
let
  eww-base = withWayland: prev.rustPlatform.buildRustPackage rec {
    pname = "eww";
    version = "git-${if withWayland then "wayland" else "x"}";

    src = inputs.eww-src;
    cargoSha256 = "sha256-lTy3fIgBQAWODbBTDxqksA+aJHSF/xeFHMoHymVijk0=";

    cargoLock = {
      lockFile = "${inputs.eww-src}/Cargo.lock";
    };

    nativeBuildInputs = [ prev.pkg-config ];
    buildInputs = [ prev.gtk3 ] ++ prev.lib.optional withWayland prev.gtk-layer-shell;

    buildNoDefaultFeatures = withWayland;
    buildFeatures = prev.lib.optional withWayland "wayland";

    cargoBuildFlags = [ "--bin" "eww" ];
    cargoTestFlags = cargoBuildFlags;

    # requires unstable rust features
    RUSTC_BOOTSTRAP = 1;
  };
in
{
  eww-git = eww-base false;
  eww-git-wayland = eww-base true;
}
