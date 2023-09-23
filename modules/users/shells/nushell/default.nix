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
      inherit (config.home) shellAliases;
      extraConfig = ''
        $env.config = {
          # ...other config...
          edit_mode: vi
          hooks: {
            pre_execution: {
              let cmd = (commandline | str trim)

              if $cmd == "" {
                run-external "eza"
                run-external "command" "git" "-c" "color.status=always" "status" "-sb" "2>/dev/null"
              }
            }
          }
          keybindings: []
        }
      '';
    };
  };
}
