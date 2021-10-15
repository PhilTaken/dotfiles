{ pkgs, home-manager, system, lib, overlays, extramodules, ... }:
rec {
  user = import ./user.nix { inherit pkgs home-manager lib system overlays; };
  host = import ./host.nix { inherit system pkgs home-manager lib user extramodules; };
  shells = import ./shells.nix { inherit pkgs; };
}
