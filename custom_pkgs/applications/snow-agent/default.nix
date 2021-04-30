{
  stdenv,
  dpkg,
  glibc,
  gcc-unwrapped,
  autoPatchelfHook,
  requireFile,
}: let
  version = "6.2.3-1";
  src = requireFile {
    name = "fzj_prod_linux_debian_${version}_amd64.deb";
    sha256 = "1drvyj8djb9agjbp2y8bdvvig65vy90nn1j8a0764irmn7nvhvm6";
    message = "Run nix-prefetch-url on the file first";
  };
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
