{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkOption types mkIf;
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

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      chrome-gnome-shell
      # gnome3 apps
      gnome.eog # image viewer
      gnome.evince # pdf reader

      # desktop look & feel
      gnome.gnome-tweaks

      # extensions
      gnomeExtensions.dash-to-dock
      gnomeExtensions.appindicator
      gnomeExtensions.gsconnect
    ];
  };
}

