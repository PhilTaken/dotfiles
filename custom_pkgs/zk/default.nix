{
  stdenv,
  autoPatchelfHook,
  fetchzip,
  icu63,
}:
stdenv.mkDerivation rec {
  pname = "zk";
  version = "0.6.0";

  src = fetchzip {
    name = "zk-src";
    url = "https://github.com/mickael-menu/zk/releases/download/v${version}/zk-v${version}-linux-amd64.tar.gz";
    sha256 = "sha256-RnLCNVB2rOu1b6n/TzmiKW4Blzp6dkY0Pb1a8d5dYrI=";
  };

  buildInputs = [icu63];
  nativeBuildInputs = [autoPatchelfHook];
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    mv zk $out/bin
  '';
}
