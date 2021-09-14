{ stdenv
, autoPatchelfHook
, fetchurl
, gfortran
}:

stdenv.mkDerivation rec {
  pname = "fortran-fpm";
  version = "0.4.0";

  fpm-src = fetchurl {
    url = "https://github.com/fortran-lang/fpm/releases/download/v${version}/fpm-${version}.F90";
    sha256 = "sha256-9pwYNk5Dyh72nhn0TCjikp4wwbM9eIIduW2knwhpY/k=";
  };

  fpm-default-toml = fetchurl {
    url = "https://raw.githubusercontent.com/fortran-lang/fpm/v${version}/fpm.toml";
    sha256 = "sha256-Vx39k6zgU37b6IJqCW35QImm+220AWI8HXTc+P/Bjbs=";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    gfortran
  ];

  buildPhase = ''
    FC="${gfortran}/bin/gfortran"
    FFLAGS="-g -fbacktrace -O3"
    PREFIX="$out/bin"
    BOOTSTRAP_DIR="build"

    mkdir -p $BOOTSTRAP_DIR
    cp -r ${fpm-src} $BOOTSTRAP_DIR/fpm.F90
    $FC $FFLAGS -J $BOOTSTRAP_DIR $BOOTSTRAP_DIR/fpm.F90 -o $BOOTSTRAP_DIR/fpm
  '';

  installPhase = ''
    mkdir -p $PREFIX
    cp $BOOTSTRAP_DIR/fpm $PREFIX
    rm -r $BOOTSTRAP_DIR
  '';
}
