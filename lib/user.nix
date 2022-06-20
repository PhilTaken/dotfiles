{ pkgs
, home-manager
, lib
, system
, overlays
, extraHMImports
, ...
}:
with builtins;
{
  mkConfig = { username
  , userConfig
  , extraPackages ? pkgs: []
  , stateVersion ? "21.05"
  , homeDirectory ? "/home/${username}"
  }: rec {
    phil = userConfig;
    nixpkgs.overlays = overlays;
    nixpkgs.config.allowUnfree = true;
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
        qt5.qtbase
        weather-icons
        hicolor-icon-theme

        anki
        cachix

        element-desktop
        gimp
        gping
        hyperfine
        keepassxc
        libreoffice
        #magic-wormhole
        #obsidian
        signal-desktop
        tdesktop
        texlive.combined.scheme-medium
        tokei
        vpnc
        wget
        youtube-dl
        zoom-us
      ] ++ (extraPackages pkgs) ++
      # TODO: resolve with https://github.com/NixOS/nixpkgs/issues/159267
      #discord
      (if phil.wms.sway.enable or false then [
        (pkgs.writeShellApplication {
          name = "discord";
          text = "${pkgs.discord}/bin/discord --use-gl=desktop";
        })
        (pkgs.makeDesktopItem {
          name = "discord";
          exec = "discord";
          desktopName = "Discord";
        })
      ]
      else [ discord ]);
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

    imports = [
      ../modules/users
    ] ++ extraHMImports;
  };

  mkHMUser = { config }: home-manager.lib.homeManagerConfiguration {
    inherit system pkgs;
    inherit (config.home) username homeDirectory stateVersion;
    configuration = mkConfig args;
  };

  mkNixosModule = { config }: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.${config.home.username} = config;
  };

  mkSystemUser =
    { name
    , uid ? null
    , shell ? pkgs.zsh
    , groups ? [ "wheel" "video" "audio" "docker" "dialout" "adbusers" "gpio" "cdrom" ]
    , sshKeys ? [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoABVjBx1az00D8EBjw9/NS9luqO2lN4Y87/2xsQqPTx9P7aXzfX53TwmU9Wpmp7qOIKykd8GSkBdCizMEzgaGmJl6+Di2GYvEfN0NrsLdBrjmIh7AQyR6UbY7qoTFjZ28864rk9QV9to2R1APL7o1wzdmCrFtTsemV+lw9MglqcPLT+ae2mba9fD84FFDmcSJMg5x1QHrO5GuWg/Ng7SE1eRhDbDmz66+HhdgvRRDJ9VwPGcH5ruXsDKvi/nrLVSxw7afvuM5KcNYoy+9CrA/N10cO5zdn4/q2DLYujkOvAucCDJ4bUEe8q6xEZw1LfCjKWIoFxzt+hetfkjS/Y3wWWTcHfcOx/BV6cOxyAFUGbu9RX/iUpyt8LAfjQv6L1zcD7vxYpfKz88jI/4zL7mHwILg+XQklBeiBsEQ4PyO1+4oIfuju241hVk+bFZYUD+AzzCNv7GKNNHe4aa4MWN6RLLhNxe9QlOTnsw0l2XNypr62Q1V8nxZkSY7mW8Hn0hLxTT82mTLuAff2yHPu+w+i0ELkk0BO28apxU1dPPbScHvojRlXTwIBvH3HN6TWdj2YnNFMdGvZgxxFNbi4l/7Gar1FKgi79KOwcm89ATmjONfbQMub+TaeBACefMZ9Q7uzbWeNO3mZpVA8nvM5eleqLemxYoeAQBuYjBjJlAHzQ== cardno:000614321676"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoABVjBx1az00D8EBjw9/NS9luqO2lN4Y87/2xsQqPTx9P7aXzfX53TwmU9Wpmp7qOIKykd8GSkBdCizMEzgaGmJl6+Di2GYvEfN0NrsLdBrjmIh7AQyR6UbY7qoTFjZ28864rk9QV9to2R1APL7o1wzdmCrFtTsemV+lw9MglqcPLT+ae2mba9fD84FFDmcSJMg5x1QHrO5GuWg/Ng7SE1eRhDbDmz66+HhdgvRRDJ9VwPGcH5ruXsDKvi/nrLVSxw7afvuM5KcNYoy+9CrA/N10cO5zdn4/q2DLYujkOvAucCDJ4bUEe8q6xEZw1LfCjKWIoFxzt+hetfkjS/Y3wWWTcHfcOx/BV6cOxyAFUGbu9RX/iUpyt8LAfjQv6L1zcD7vxYpfKz88jI/4zL7mHwILg+XQklBeiBsEQ4PyO1+4oIfuju241hVk+bFZYUD+AzzCNv7GKNNHe4aa4MWN6RLLhNxe9QlOTnsw0l2XNypr62Q1V8nxZkSY7mW8Hn0hLxTT82mTLuAff2yHPu+w+i0ELkk0BO28apxU1dPPbScHvojRlXTwIBvH3HN6TWdj2YnNFMdGvZgxxFNbi4l/7Gar1FKgi79KOwcm89ATmjONfbQMub+TaeBACefMZ9Q7uzbWeNO3mZpVA8nvM5eleqLemxYoeAQBuYjBjJlAHzQ== (none)"
      ]
    , ...
    }:
    {
      users.users."${name}" = {
        inherit name uid shell;
        isNormalUser = true;
        isSystemUser = false;
        extraGroups = groups;
        openssh.authorizedKeys.keys = sshKeys;
      };
    };
}
