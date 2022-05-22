{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.wms.xmonad;
in
{
  options.phil.wms.xmonad = {
    enable = mkOption {
      description = "enable xmonad module";
      type = types.bool;
      default = false;
    };

    # more options
  };

  config = mkIf (cfg.enable) {
    xsession.windowManager.xmonad = rec {
      enable = true;
      extraPackages = hPkgs: with hPkgs; [
        xmonad-contrib
        containers
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

