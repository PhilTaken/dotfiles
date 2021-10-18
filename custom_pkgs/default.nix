final: prev: {
  zettlr = prev.callPackage ./applications/zettlr { };
  calibre = prev.callPackage ./applications/calibre { };
  fortls = prev.callPackage ./applications/fortls { };
  snow-agent = prev.callPackage ./applications/snow-agent { };
  goneovim = prev.callPackage ./applications/goneovim { };
  zk = prev.callPackage ./applications/zk { };

  fortran-package-manager = prev.callPackage ./applications/fortran-package-manager { };
}
