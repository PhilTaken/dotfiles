{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.phil.wms;
in {
  imports = [
    ./xmonad
    ./sway
    ./i3
    ./hyprland

    ./bars
    ./tools
  ];
}
