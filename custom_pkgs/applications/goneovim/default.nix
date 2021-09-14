{ stdenv
, qt5
, autoPatchelfHook
, fetchzip
}:

stdenv.mkDerivation rec {
  pname = "goneovim";
  version = "0.4.11";

  src = fetchzip {
    name = "goneovim-src";
    url = "https://github.com/akiyosi/goneovim/releases/download/v${version}/Goneovim-${version}-linux.tar.bz2";
    sha256 = "sha256-WC07E5jck1Oe5bZpJKPjbJCN0Nz3Y1E31qvC2E8jjtg=";
  };

  buildInputs = with qt5; [ full ];
  nativeBuildInputs = [ autoPatchelfHook ];
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    mv goneovim $out/bin
  '';
}
