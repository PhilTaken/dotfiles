with import <nixpkgs> {};

stdenv.mkDerivation rec {
  pname = "rofi-wayland";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "lbonn";
    repo = "rofi";
    rev = "${version}-wayland";
    fetchSubmodules = true;
    sha256 = "1n1hkv14qfcqfc15h4qswjxiagd9xps9n0zcrwmkrkmd6bi0w3ra";
  };

  configurePhase = ''
    mkdir -p $out/bin
    meson setup build --prefix=$out
  '';

  buildPhase = ''
    meson build -Dwayland=enabled
  '';

  installPhase = ''
    ninja -C build install
  '';

  baseInputs = [
    findutils
    patchelf
  ];

  buildInputs = [
    # building
    meson
    cmake
    pkg-config
    flex
    bison
    ninja

    # external libraries
    pango
    cairo 
    glib 
    gdk-pixbuf
    libstartup_notification
    libxkbcommon
    xorg.libxcb
    xorg.xcbutilwm
    xcbutilxrm 

    # wayland support
    wayland
    wayland-protocols
  ];

  doCheck = false;
  meta = with lib; {
    description = "Window switcher, run dialog and dmenu replacement (Wayland fork)";
    homepage = "https://github.com/lbonn/rofi";
    license = licenses.mit;
    platforms = with platforms; linux;
  };
}
