{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.zellij;
  configDir =
    if pkgs.stdenv.isDarwin then
      "Library/Application Support/org.Zellij-Contributors.Zellij"
    else
      "${config.xdg.configHome}/zellij";

  settings = import ./config.nix { inherit pkgs cfg; };
in
{
  options.phil.zellij = {
    enable = mkEnableOption "zellij";
    defaultShell = mkOption {
      type = types.enum [ "fish" "zsh" ];
      default = "zsh";
    };
  };

  config = mkIf cfg.enable {
    home.file."${configDir}/config.kdl" = {
      source = settings.configFile;
    };
  };
}
