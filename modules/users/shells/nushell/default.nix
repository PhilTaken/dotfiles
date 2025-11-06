{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.phil.shells.nushell;
  inherit (lib) mkIf mkOption;
in
{
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
      extraEnv = ''
        if (uname) == "Darwin" {
          $env.PATH = $env.PATH | split row (char esep)
            | prepend /run/current-system/sw/bin
            | prepend $'/etc/profiles/per-user/($env.USER)/bin'
            | append /nix/var/nix/profiles/default/bin
            | uniq
        }
      ''
      + (builtins.concatStringsSep "\n" (
        builtins.attrValues (
          builtins.mapAttrs (n: v: "$env.${n} = ${builtins.toString v}") (
            lib.filterAttrs (
              n: _:
              builtins.elem n [
                "GIT_WORKSPACE"
                "EDITOR"
                "GNUPGHOME"
                "DIRENV_WARN_TIMEOUT"
                "PASSWORD_STORE_DIR"
                "XDG_CACHE_HOME"
                "XDG_CONFIG_HOME"
                "XDG_DATA_HOME"
                "XDG_STATE_HOME"
                "_ZO_ECHO"
                "_Z_DATA"
                "_FASD_DATA"
              ]
            ) config.home.sessionVariables
          )
        )
      ))
      + (lib.optionalString
        (config.phil.gpg.enable && lib.hasInfix "darwin" pkgs.stdenv.hostPlatform.system)
        ''

          $env.GPG_TTY = (tty)
          $env.SSH_AUTH_SOCK = (gpgconf --list-dirs agent-ssh-socket)
          gpgconf --launch gpg-agent

        ''
      );

      extraConfig = ''
        $env.config = {
          # ...other config...
          edit_mode: vi
          hooks: {
            pre_execution: {
              let cmd = (commandline | str trim)

              if $cmd == "" {
                run-external "eza"
                if (do { git rev-parse --is-inside-work-tree } | complete).exit_code == 0 {
                  run-external "git" "status" "-sb"
                }
              }
            }
          }
          keybindings: []
        }

        # A git workspace selector
        def-env pri [
          ...filter: string # filter for the initial selection
        ] {
          let chosen_project = (git workspace list | sk -q (echo $filter | str join " "))
          if (echo $chosen_project | str length) > 0 {
            cd $"($env.GIT_WORKSPACE)/($chosen_project)"
          }
        }
      '';
      # TODO: autostart zellij in nushell
      #+ (lib.optionalString (config.phil.terminals.multiplexer == "zellij") ''
      #if status is-interactive
      #and not status --is-login
      #and not set -q TMUX
      #and not set -q NVIM
      #and set -q DISPLAY
      #and not set -q ZELLIJ
      #zellij attach --create main
      #end
      #'');
    };
  };
}
