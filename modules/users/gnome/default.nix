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
    programs = {
      alacritty = {
        enable = true;
        settings = {
          font.normal.family = "iosevka";
          font.size = 12.0;
        };
      };
    };

    home.packages = with pkgs; [
      chrome-gnome-shell
    ];
  };
}

