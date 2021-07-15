{ stdenv
, autoPatchelfHook
, fetchzip}:

stdenv.mkDerivation rec {
  pname = "zk";
  version = "0.6.0";

  src = fetchzip {
    name = "zk-src";
    url = "https://github.com/mickael-menu/zk/releases/download/v${version}/zk-v${version}-linux-amd64.tar.gz";
    sha256 = "185yy9haqgg036rrhsxvybja44n5sk0c8jmsfvhmnllxibmgrq3c";
  };

  #buildInputs = with qt5; [ full ];
  nativeBuildInputs = [ autoPatchelfHook ];
  dontBuild = true;

  installPhase = ''
      mkdir -p $out/bin
      mv zk $out/bin
  '';
}
