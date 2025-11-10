{ pkgs, ... }:
let
  darwin-fixes = import ./darwin-fixes.nix;
in
{
  services.sketchybar = {
    enable = true;
    extraPackages = [ pkgs.jq ];
  };

  fonts.packages = [
    pkgs.sketchybar-app-font
  ];

  home-manager.users.philippherzog = {
    imports = [
      darwin-fixes.home-manager
    ];

    home.packages = [
      (pkgs.tuir.overrideAttrs { doCheck = false; })
    ];

    fonts.fontconfig.enable = true;

    xdg.configFile."sketchybar/sketchybarrc".source = ./sketchybarrc;
    xdg.configFile."sketchybar/plugins/" = {
      source = ./sketchybarplugins;
      recursive = true;
    };
  };
}
