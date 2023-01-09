{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.zellij;
  settings = import ./config.nix { inherit pkgs cfg; };
in
{
  options.phil.zellij = {
    enable = mkEnableOption "zellij";
    defaultShell = mkOption {
      type = types.nullOr (types.enum [ "fish" "zsh" ]);
      default = null;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.zellij
    ];

    xdg.configFile."zellij/config.kdl" = {
      source = settings.configFile;
    };

    xdg.configFile."zellij/layouts" = {
      source = ./layouts;
      recursive = true;
    };
  };
}
