{ pkgs
, home-manager
, lib
, system
, overlays
, extraHMImports
, ...
}:
with builtins;
rec {
  mkConfig =
    { username
    , userConfig
    , extraPackages ? pkgs: [ ]
    , stateVersion ? "21.05"
    , homeDirectory ? "/home/${username}"
    }: {
      phil = userConfig;
      systemd.user.startServices = true;
      home = {
        inherit username homeDirectory stateVersion;

        sessionVariables = {
          MOZ_USE_XINPUT2 = 1;
          GTK_USE_PORTAL = 1;
          AWT_TOOLKIT = "MToolkit";
        };

        packages = with pkgs; [
          cacert
          coreutils
          hicolor-icon-theme
          qt5.qtbase
          weather-icons

          #magic-wormhole
          cachix
          gping
          hyperfine
          #texlive.combined.scheme-medium
          tokei
          #vpnc
          wget
          youtube-dl

          #obsidian
          #anki
          element-desktop
          #gimp
          #keepassxc
          libreoffice
          signal-desktop
          tdesktop
          #zoom-us
        ] ++ (extraPackages pkgs) ++
        # TODO: resolve with https://github.com/NixOS/nixpkgs/issues/159267

        #discord
        (if true then [
          (pkgs.writeShellApplication {
            name = "discord";
            text = "${pkgs.discord}/bin/discord --use-gl=desktop --disable-gpu-sandbox";
          })
          (pkgs.makeDesktopItem {
            name = "discord";
            exec = "discord";
            desktopName = "Discord";
          })
        ] else [ discord ]);
      };

      programs.home-manager.enable = true;
      programs.zathura.enable = true;

      services.syncthing.enable = true;

      xdg = {
        enable = true;
        configHome = "${homeDirectory}/.config";
        dataHome = "${homeDirectory}/.local/share";
        cacheHome = "${homeDirectory}/.cache";
      };

      imports = [ ../modules/users ] ++ extraHMImports;
    };

  mkHMUser = config: home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [ (mkConfig config) ];
  };

  mkNixosModule = config: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.${config.username} = mkConfig config;
  };

  mkSystemUser =
    { name
    , uid ? 1000
    , shell ? pkgs.zsh
    , extraGroups ? [ "wheel" "docker" "dialout" "adbusers" "gpio" "fuse" ]
    , sshKeys ? [
        # yubikey
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoABVjBx1az00D8EBjw9/NS9luqO2lN4Y87/2xsQqPTx9P7aXzfX53TwmU9Wpmp7qOIKykd8GSkBdCizMEzgaGmJl6+Di2GYvEfN0NrsLdBrjmIh7AQyR6UbY7qoTFjZ28864rk9QV9to2R1APL7o1wzdmCrFtTsemV+lw9MglqcPLT+ae2mba9fD84FFDmcSJMg5x1QHrO5GuWg/Ng7SE1eRhDbDmz66+HhdgvRRDJ9VwPGcH5ruXsDKvi/nrLVSxw7afvuM5KcNYoy+9CrA/N10cO5zdn4/q2DLYujkOvAucCDJ4bUEe8q6xEZw1LfCjKWIoFxzt+hetfkjS/Y3wWWTcHfcOx/BV6cOxyAFUGbu9RX/iUpyt8LAfjQv6L1zcD7vxYpfKz88jI/4zL7mHwILg+XQklBeiBsEQ4PyO1+4oIfuju241hVk+bFZYUD+AzzCNv7GKNNHe4aa4MWN6RLLhNxe9QlOTnsw0l2XNypr62Q1V8nxZkSY7mW8Hn0hLxTT82mTLuAff2yHPu+w+i0ELkk0BO28apxU1dPPbScHvojRlXTwIBvH3HN6TWdj2YnNFMdGvZgxxFNbi4l/7Gar1FKgi79KOwcm89ATmjONfbQMub+TaeBACefMZ9Q7uzbWeNO3mZpVA8nvM5eleqLemxYoeAQBuYjBjJlAHzQ== cardno:000614321676"
        # nix remote building
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8KpkIxe5zytz/Vv2kcSivSQ2KALMVCihYDZTfUZP04wDYhn/Sg/lHiTo7n1IE39w9JtmEaK003/7MKX04s1qA6ZI9H9Buq6QlyqClwIizwnMJa7Qbfv6C+WCEtGdU6Mdoam/4jZY9wNol4d1vjfStafkPDJqGDJaN/8KuPl9sVniUaFwMvxblzBC2RaStCUnwZMkAMi9V7re86PyfL7am7S9DwtxinTuaEqXe63b0k5RHjhPSVPAMFuItgnQOJUNa9vuD5x2Ao6pBMSpt0FSgwv13JHTC8Is3NgUofV4Vrt5nqv50aK+9pwpFOnjnvP5+lK//uqjMNRwPUG5ObKjA+4SDxfWUZ+cjQZ78U9LOyrRoqDF0fLCcLSpdRw6gZw4nN4pgowW4L/D1lO9FnZKwFVfdLMg0Fq/Q1X5VO+Jd0aPdE4MzmrAg34MxwX/qcZbz9vpRojz3G8C3+/bIFVAq4SP/l6RfdMPiwSn69wgKnu3/1EMwhjQnO+VdLS42ZPM= maelstroem@epsilon"
      ]
    , ...
    }: mkUser { inherit uid name shell extraGroups sshKeys; };

  mkGuestUser = { name, uid ? 1000, shell ? pkgs.zsh, extraGroups ? [ ] }@args: mkUser args;

  mkUser =
    { name
    , uid
    , shell
    , extraGroups
    , sshKeys ? [ ]
    }: {
      users.users."${name}" =
        let
          defaultGroups = [ "video" "audio" "cdrom" "fuse" ];
        in
        {
          inherit name uid shell;
          extraGroups = extraGroups ++ defaultGroups;
          isNormalUser = true;
          isSystemUser = false;
          openssh.authorizedKeys.keys = sshKeys;
        };
    };
}
