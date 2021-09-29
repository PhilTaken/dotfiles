{ pkgs, home-manager, lib, system, overlays, ... }:
with builtins;
{
  mkHMUser = { userConfig, username }:
    let
      homeDirectory = "/home/${username}";
      stateVersion = "21.05";
    in
    home-manager.lib.homeManagerConfiguration {
      inherit system username pkgs homeDirectory stateVersion;

      configuration = {
        phil = userConfig;
        nixpkgs.overlays = overlays;
        nixpkgs.config.allowUnfree = true;
        systemd.user.startServices = true;
        home = {
          inherit username homeDirectory stateVersion;

          # tbh no clue
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

            iosevka-bin
            (nerdfonts.override { fonts = [ "Iosevka" ]; })
          ];
        };

        programs.home-manager.enable = true;
        programs.zathura.enable = true;

        # TODO move to own module? (gpg?)
        # programs.gpg = {
        #   enable = true;
        #   #settings.default-key = usermod.gpgKey;
        # };

        services.syncthing.enable = true;

        xdg = {
          enable = true;
          configHome = "${homeDirectory}/.config";
          dataHome = "${homeDirectory}/.local/share";
          cacheHome = "${homeDirectory}/.cache";
        };

        imports = [
          ../modules/users
        ];
      };
    };

  mkSystemUser = { name, uid, shell, groups, ... }:
    {
      users.users."${name}" = {
        inherit name uid shell;
        isNormalUser = true;
        isSystemUser = false;
        extraGroups = groups;
        initialPassword = "raspberry";
      };
    };
}
