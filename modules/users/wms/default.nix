{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.phil.wms.bars;
in {
  options.phil.wms.bars = {
    barcommand = mkOption {
      description = "comand to (re)start the bar(s)";
      type = types.str;
      default = "";
    };
  };

  imports = [
    ./sway
    ./i3

    ./bars/polybar
    ./bars/eww
  ];
}
