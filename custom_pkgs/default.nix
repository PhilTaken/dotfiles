final:  prev: {
  zettlr = prev.callPackage ./applications/zettlr {  };
  calibre = prev.callPackage ./applications/calibre {  };
  fortls = prev.callPackage ./applications/fortls {  };
  snow-agent = prev.callPackage ./applications/snow-agent { };
  #neovide = prev.callPackage ./applications/neovide { };
  goneovim = prev.callPackage ./applications/goneovim { };
  fortran-fpm = prev.callPackage ./applications/fortran-fpm { };
  zk = prev.callPackage ./applications/zk { };

  tauon = prev.callPackage ./applications/tauon { };
}
