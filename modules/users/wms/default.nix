{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.phil.wms;

in {
  imports = [
    ./sway
    ./i3

    ./bars
    ./tools
  ];
}
