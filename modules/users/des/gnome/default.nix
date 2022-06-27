{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.des.gnome;
in
{
  options.phil.des.gnome = {
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
      # gnome3 apps
      gnome3.eog    # image viewer
      gnome3.evince # pdf reader

      # desktop look & feel
      gnome3.gnome-tweaks

      # extensions
      gnomeExtensions.dash-to-dock
      gnomeExtensions.appindicator
      gnomeExtensions.gsconnect
    ];
  };
}

