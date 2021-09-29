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
