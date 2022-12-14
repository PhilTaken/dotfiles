{ config
, pkgs
, lib
, ...
}:
with lib;

{
  options.phil.wms.bars = {
    barcommand = mkOption {
      description = "command to (re)start the bar(s)";
      type = types.str;
      default = "";
    };
  };

  imports = [
    ./eww
    ./waybar
    ./polybar
  ];
}
