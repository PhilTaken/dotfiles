{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.phil.shells.nushell;
  inherit (lib) mkIf mkOption;
in {
  options.phil.shells.nushell = {
    enable = mkOption {
      description = "nushell";
      default = config.phil.terminals.defaultShell == "nushell";
      type = lib.types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs.nushell = {
      enable = true;
      shellAliases = config.home.shellAliases;
    };
  };
}
