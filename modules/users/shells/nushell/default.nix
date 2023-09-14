{
  pkgs,
  config,
  lib,
  inputs,
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
    home.packages = [pkgs.atuin];

    programs.nushell = {
      enable = true;

      loginFile.text = ''
        mkdir ~/.local/share/atuin/
        atuin init nu --disable-up-arrow | save ~/.local/share/atuin/init.nu
      '';
    };
  };
}
