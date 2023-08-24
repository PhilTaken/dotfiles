{hello, ...}: hello
#{ fetchFromGitHub,
#racket2nix ? fetchFromGitHub {
#owner = "fractalide";
#repo = "racket2nix";
#rev = "59c614406d4796f40620f6490b0b05ecb51ed976";
#sha256 = "0z5y1jm60vkwvi66q39p88ygkgyal81486h577gikmpqjxkg9d6i";
#},
#pkgs,
#...
#}: let
# maybe do this here?
#pkgs = {
#pkgs ? import (import ../nixpkgs) {},
#system ? builtins.currentSystem,
#racket-minimal ? pkgs.racket-minimal,
#...}@args: let
#nixpkgs = pkgs;
#inherit (nixpkgs) bash lib newScope racket;
#inherit (lib) makeScope;
#in
#makeScope newScope (self: {
#pkgs = self;
#callPackageFull = (makeScope self.newScope (fullself: nixpkgs // self //
#{ pkgs = fullself; extend = fullself.overrideScope'; })).callPackage;
#extend = self.overrideScope';
#racket-full = racket;
#inherit racket-minimal;
#racket = self.racket-minimal;
#buildDrvs = name: buildInputs: derivation {
#inherit name buildInputs system;
#builder = bash + "/bin/bash";
#args = [ "-c" "echo -n > $out" ];
#};
#racket2nix-stage0 = self.callPackage ../stage0.nix {};
#racket2nix-stage1 = self.callPackage ../stage1.nix {};
#racket2nix = self.buildRacketPackage "racket2nix";
#inherit (self.callPackage ../build-racket.nix {})
#buildRacket buildRacketPackage buildRacketCatalog
#buildThinRacket buildThinRacketPackage;
#});
#r2nix = import racket2nix {
#pkgs = import "${racket2nix}/pkgs" {
#inherit (pkgs) system;
#};
#inherit (pkgs) system;
#};
#langserver-src = fetchFromGitHub {
#owner = "jeapostrophe";
#repo = "racket-langserver";
#rev = "3c3c217cced27788fb342ffcc82c87714b5a8082";
#sha256 = "0000000000000000000000000000000000000000000000000000";
#};
#in r2nix.buildRacketPackage langserver-src

