{ self, inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  inherit (builtins) readDir elem attrValues;
in
{
  flake = {
    nixosModules = lib.mapAttrs
      (n: _: import (../. + "/hosts/${n}"))
      (lib.filterAttrs
        (_: v: v == "directory")
        (readDir ../hosts));

    hmModules = lib.recursiveUpdate
      (lib.mapAttrs
        (n: _: import (../. + "/users/${n}"))
        (lib.filterAttrs
          (dir: type: type == "directory" &&
            (elem "default.nix" (attrValues (readDir (../. + "/users/${dir}")))))
          (readDir ../users)))
      { all = import ../users; };
  };
}
