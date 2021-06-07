{ stdenv
, autoPatchelfHook
, fetchurl
, gfortran10
}:

stdenv.mkDerivation rec {
  pname = "fortran-fpm";
  version = "0.2.0";

  src = fetchurl {
    url = "https://github.com/fortran-lang/fpm/releases/download/v${version}/fpm-${version}.f90";
    sha256 = "0gj6vqg42867yyhal3xxglk1924dz2sv65whk7zsvlgbbhgh9mbr";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
    gfortran10
  ];

  buildInputs = [
    gfortran10
  ];

  buildPhase = ''
    gfortran ${src} -o fpm
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv fpm $out/bin
  '';
}
