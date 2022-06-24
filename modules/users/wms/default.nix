{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.phil.wms;

in
{
  imports = [
    ./xmonad
    ./sway
    ./i3

    ./bars
    ./tools
  ];
}
