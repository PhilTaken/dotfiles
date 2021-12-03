final: prev: {
  zettlr = prev.callPackage ./applications/zettlr { };
  calibre = prev.callPackage ./applications/calibre { };
  fortls = prev.callPackage ./applications/fortls { };
  snow-agent = prev.callPackage ./applications/snow-agent { };
  goneovim = prev.callPackage ./applications/goneovim { };
  zk = prev.callPackage ./applications/zk { };

  fortran-package-manager = prev.callPackage ./applications/fortran-package-manager { };

  hydroxide = prev.callPackage (
    { lib, buildGoModule, fetchFromGitHub, fetchpatch }:

    buildGoModule rec {
      pname = "hydroxide";
      version = "0.2.21";

      src = fetchFromGitHub {
        owner = "emersion";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-fF+pQnqAWBktc4NdQFTHeB/sEg5bPTxXtdL1x5JuXU8=";
      };

      vendorSha256 = "sha256-M5QlhF2Cj1jn5NNiKj1Roh9+sNCWxQEb4vbtsDfapWY=";

      doCheck = false;

      subPackages = [ "cmd/hydroxide" ];
    }) {};
}
