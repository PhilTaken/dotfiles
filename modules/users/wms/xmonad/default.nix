{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.wms.xmonad;
in
{
  options.phil.wms.xmonad = {
    enable = mkEnableOption "xmonad";
  };

  config = mkIf cfg.enable {
    xsession.enable = true;
    xsession.windowManager.xmonad = {
      enable = true;
      extraPackages = hPkgs: with hPkgs; [
        containers
        dbus
        List
        monad-logger
        xmonad
      ];
      enableContribAndExtras = true;
      config = ./Main.hs;

      libFiles = {
        "Tools.hs" = pkgs.writeText "Tools.hs" ''
          module Tools where

          screenshot = "scrot"
        '';
      };
    };

    home.packages = with pkgs; [
      acpi
      betterlockscreen
      dunst
      feh
      picom

      clipcat
    ];
  };
}

