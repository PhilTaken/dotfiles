{
  config, pkgs, lib, ...
}:
with lib;

let

in {
  options.phil.wms.bars = {
    barcommand = mkOption {
      description = "comand to (re)start the bar(s)";
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
