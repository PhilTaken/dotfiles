{...}: let
  darwin-fixes = import ./darwin-fixes.nix;
in {
  home-manager.users.philippherzog = {
    imports = [
      darwin-fixes.home-manager
    ];

    fonts.fontconfig.enable = true;
    disabledModules = ["targets/darwin/linkapps.nix"];
  };
}
