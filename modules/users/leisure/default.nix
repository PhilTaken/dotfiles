{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf;
  cfg = config.phil.leisure;
in {
  options.phil.leisure = {
    enable = mkOption {
      type = lib.types.bool;
      default = !lib.hasInfix "darwin" pkgs.system;
    };
  };

  config = mkIf cfg.enable {
    # these just dont work on mac, TODO: move someplace else
    home.packages = with pkgs;
      [
        magic-wormhole
        youtube-dl

        lshw
        psmisc
        usbutils
      ]
      ++ (lib.optionals (!config.phil.headless) [
        keepassxc
        signal-desktop
        tdesktop
        anki
        element-desktop
        gimp
        #devdocs-desktop

        #liberation fonts broken
        #libreoffice

        # TODO: resolve with https://github.com/NixOS/nixpkgs/issues/159267
        #discord
        (
          if true
          then [
            (pkgs.writeShellApplication {
              name = "discord";
              text = "${pkgs.discord}/bin/discord --use-gl=desktop --disable-gpu-sandbox";
            })
            (pkgs.makeDesktopItem {
              name = "discord";
              exec = "discord";
              desktopName = "Discord";
            })
          ]
          else [pkgs.discord]
        )
      ]);
  };
}
