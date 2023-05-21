{lib, ...}: let
  inherit (lib) mkOption types;
in {
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
