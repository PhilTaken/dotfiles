{
  stdenv,
  dpkg,
  glibc,
  gcc-unwrapped,
  autoPatchelfHook
}: let
  version = "6.2.3-1";
  src = ./fzj_prod_linux_debian_6.2.3-1_amd64.deb;
  snowconfig = ./snowagent.config;
  snowcronconfig = ./snowcron.config;
in stdenv.mkDerivation {
  name = "snow-agent-${version}";
  system = "x86_64-linux";
  inherit src;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
  ];

  # Required at running time
  buildInputs = [
    glibc
    gcc-unwrapped
  ];

  unpackPhase = "true";

  # Extract and copy executable in $out/bin
  installPhase = ''
    mkdir -p $out
    dpkg -x $src $out
    rm -rf $out/opt/snow/snowagent.config
    cp -av ${snowconfig} $out/opt/snow/snowagent.config
    cp -av ${snowcronconfig} $out/opt/snow/snowcron.config
  '';

  meta = with stdenv.lib; {
    description = "Snow Agent";
    platforms = [ "x86_64-linux" ];
  };
}
