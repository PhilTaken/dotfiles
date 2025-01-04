{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.phil.des.kde;
  inherit (lib) mkEnableOption mkOption types mkIf;
in {
  options.phil.des.kde = {
    enable = mkEnableOption "kde";

    default_font = mkOption {
      description = "default font";
      type = types.str;
      default = "Iosevka Comfy";
    };
  };

  config = mkIf cfg.enable {
    services.kdeconnect.enable = true;

    home.packages = with pkgs; [
      flameshot
      latte-dock
      libnotify
      plasma-browser-integration
      rofi
      #rofi-pass
      xclip

      libsForQt5.bismuth
    ];
  };
}
