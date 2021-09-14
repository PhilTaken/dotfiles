final: prev: {
  zettlr = prev.callPackage ./applications/zettlr { };
  calibre = prev.callPackage ./applications/calibre { };
  fortls = prev.callPackage ./applications/fortls { };
  snow-agent = prev.callPackage ./applications/snow-agent { };
  goneovim = prev.callPackage ./applications/goneovim { };
  fortran-fpm = prev.callPackage ./applications/fortran-fpm { };
  zk = prev.callPackage ./applications/zk { };

  tauon = prev.callPackage ./applications/tauon { };
  fortran-package-manager = prev.callPackage ./applications/fortran-package-manager { };
  #neovide = prev.callPackage ./applications/neovide { };
}
