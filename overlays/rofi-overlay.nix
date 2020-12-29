{ ... }:
let
  rofi_overlay = final: prev: {
    rofi = prev.rofi-unwrapped.overrideAttrs (old: {
      pname = "rofi-lbonn";
      src = prev.fetchFromGitHub {
        owner = "lbonn";
        repo = "rofi";
        rev = "1.6.1-wayland";
        fetchSubmodules = true;
        sha256 = "1n1hkv14qfcqfc15h4qswjxiagd9xps9n0zcrwmkrkmd6bi0w3ra";
      };
      buildInputs = with prev; old.buildInputs ++ [
        meson
        ninja
        wayland
        wayland-protocols
      ];
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
    });
  };
in rofi_overlay
