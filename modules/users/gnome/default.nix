{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.gnome;
in
{
  options.phil.gnome = {
    enable = mkOption {
      description = "enable gnome module";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      chrome-gnome-shell
      flameshot
      foot
    ];
  };
}

