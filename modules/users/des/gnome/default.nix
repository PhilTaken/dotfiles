{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.des.gnome;
in {
  options.phil.des.gnome = {
    enable = mkEnableOption "gnome";
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
