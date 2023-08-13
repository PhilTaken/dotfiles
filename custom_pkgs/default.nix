final: prev: {
  racket-langserver = prev.callPackage ./racket-langserver {};

  # qt5 insceure currently
  #goneovim = prev.callPackage ./goneovim {};

  fortls = prev.callPackage ./fortls {};
  fortran-package-manager = prev.callPackage ./fortran-package-manager {};
  zettlr = prev.callPackage ./zettlr {};
  zk = prev.callPackage ./zk {};
}
