{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, openssl
, cmake
, freetype
, file
, expat
, curl
, SDL2
}:

rustPlatform.buildRustPackage rec {
  pname = "neovide";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "Kethku";
    repo = "neovide";
    rev = "${version}";
    sha256 = "sha256-NajO3mPPmdgQbYwS8wXKpLJVXsZ8gG71SQdWB4CGVPY=";
  };

  cargoSha256 = "sha256-NQrslwqacXIx4jZRs6kAX2gkUyhrMZo+jFLr6z3Aj/Y=";

  nativeBuildInputs = [
    pkg-config
    cmake
    curl
  ];

  buildInputs = [
    openssl
    freetype
    file
    expat
    SDL2
  ];

  configureFlags = [
    "FREETYPE_INCLUDES=${freetype.dev}/include"
    "FREETYPE_LIBS=${freetype.out}/lib"
    "FONTCONFIG_FILE=${fontconfig.out}/etc/fonts/fonts.conf"
  ];
}
