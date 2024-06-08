{pkgs, ...}: let
  darwin-fixes = import ./darwin-fixes.nix;
in {
  services.sketchybar = {
    enable = true;
    extraPackages = [pkgs.jq];
  };

  fonts.fonts = [
    pkgs.sketchybar-app-font
  ];

  home-manager.users.philippherzog = {
    imports = [
      darwin-fixes.home-manager
    ];

    fonts.fontconfig.enable = true;
    disabledModules = ["targets/darwin/linkapps.nix"];

    xdg.configFile."sketchybar/sketchybarrc".source = ./sketchybarrc;
    xdg.configFile."sketchybar/plugins/" = {
      source = ./sketchybarplugins;
      recursive = true;
    };
  };
}
