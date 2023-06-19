{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.phil.shells.fish;
  inherit (lib) mkIf mkOption;
in {
  options.phil.shells.fish = {
    enable = mkOption {
      description = "fish";
      default = config.phil.terminals.defaultShell == "fish";
      type = lib.types.bool;
    };
  };

  config = mkIf cfg.enable {
    stylix.targets.fish.enable = false;

    programs.fish = {
      enable = true;

      functions = {
        ":wa" = "${pkgs.sl}/bin/sl";
        gitignore = "curl -sL https://www.gitignore.io/api/$argv";
        license = "curl -sL https://choosealicense.com/licenses/$argv | ${pkgs.pup}/bin/pup -p pre#license-text text{}";
        su = "command su --shell=${pkgs.fish}/bin/fish $argv";
        fix_git_perms = ''
          git diff --summary | grep --color 'mode change 100755 => 100644' | cut -d' ' -f7- | xargs -d'\n' chmod +x 2>/dev/null
          git diff --summary | grep --color 'mode change 100644 => 100755' | cut -d' ' -f7- | xargs -d'\n' chmod -x 2>/dev/null
        '';
        # TODO: dont add to history?
        magic_enter_cmd = ''
          set -l cmd
          if command git rev-parse --is-inside-work-tree &>/dev/null
            set cmd " ${pkgs.exa}/bin/exa && git status -sb"
          else
            set cmd " ${pkgs.exa}/bin/exa"
          end
          echo $cmd
        '';
        enter_ls = ''
          set -l cmd (commandline)
          if test -z "$cmd"
            commandline -r (magic_enter_cmd)
            commandline -f execute
          else
            commandline -f execute
          end
        '';
      };

      plugins = [
        {
          name = "pisces";
          src = inputs.fish-pisces-src;
        }
      ];

      interactiveShellInit =
        ''
          if test (uname) = Darwin
              fish_add_path --prepend --global /nix/var/nix/profiles/default/bin /run/current-system/sw/bin "/etc/profiles/per-user/$USER/bin"
          end

          set -U fish_greeting
          set -gx ATUIN_NOBIND "true"

          bind \t 'commandline -f complete'
          bind \e 'commandline -f cancel'
          bind \r 'enter_ls'
          bind \n 'enter_ls'

          if bind -M insert >/dev/null 2>&1
            bind -M insert \t 'commandline -f complete'
            bind -M insert \e 'commandline -f cancel'
            bind -M insert \r 'enter_ls'
            bind -M insert \n 'enter_ls'
          end
        ''
        + (lib.optionalString (config.phil.terminals.multiplexer == "zellij") ''
          if status is-interactive
          and not status --is-login
          and not set -q TMUX
          and not set -q NVIM
          and set -q DISPLAY
          and not set -q ZELLIJ
            zellij attach --create main
          end
        '');
    };
  };
}
