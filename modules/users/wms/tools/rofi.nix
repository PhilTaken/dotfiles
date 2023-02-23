{ lib
, config
, pkgs
, ...
}:

let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.phil.wms.tools.rofi;
in
{
  options.phil.wms.tools.rofi = {
    enable = mkEnableOption "rofi";
    package = mkOption {
      type = types.package;
      default = pkgs.rofi;
    };
  };

  config.programs.rofi = {
    inherit (cfg) package enable;

    extraConfig = {
      modi = "run,drun";
      icon-theme = "Oranchelo";
      show-icons = true;
      terminal = "alacritty";
      drun-display-format = "{icon} {name}";
      location = 0;
      disable-history = false;
      hide-scrollbar = true;
      display-drun = "   Apps ";
      display-run = "   Run ";
      display-Network = " 󰤨  Network";
      sidebar-mode = true;
      run-shell-command = "{terminal} --class float -e {cmd}";
    };
    theme = lib.mkForce ./catppuccin-mocha.rasi;
  };
}
