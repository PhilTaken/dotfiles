self: super: {
  zettlr = super.zettlr.overrideAttrs (old: rec {
    version = "1.8.6";
    name = "zettlr-${version}";
    src = super.fetchurl {
        url = "https://github.com/Zettlr/Zettlr/releases/download/v${version}/Zettlr-${version}-x86_64.appimage";
        sha256 = "8bdfce5ff0b4321030e15cd14c1fd6c4e3e35f803cf533b5347e61834e054f03";
    };
  });
}
