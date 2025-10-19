{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  cfg = config.phil.leisure;
in
{
  options.phil.leisure = {
    enable = mkOption {
      type = lib.types.bool;
      default = !lib.hasInfix "darwin" pkgs.stdenv.hostPlatform.system;
    };
  };

  config = mkIf cfg.enable {
    # these just dont work on mac, TODO: move someplace else
    home.packages =
      with pkgs;
      [
        #youtube-dl

        lshw
        psmisc
        usbutils
      ]
      ++ (lib.optionals (!config.phil.headless) [
        #signal-desktop
        #element-desktop

        keepassxc
        tdesktop
        anki
        gimp
        #devdocs-desktop

        #liberation fonts broken
        #libreoffice

        discord
      ]);
  };
}
