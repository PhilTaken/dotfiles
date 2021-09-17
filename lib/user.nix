{ pkgs, home-manager, lib, system, overlays, ... }:
with builtins;
{
  mkHMUser = { userConfig, username }:
    let
      homeDirectory = "/home/${username}";
    in
    home-manager.lib.homeManagerConfiguration {
      inherit system username pkgs homeDirectory;

      stateVersion = "21.05";
      configuration = {
        cfg = userConfig;
        nixpkgs.overlays = overlays;
        nixpkgs.config.allowUnfree = true;
        systemd.user.startServices = true;
        home.stateVersion = "21.05";
        home = {
          inherit username homeDirectory;
        };

        imports = [
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
