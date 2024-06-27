{
  pkgs,
  config,
  lib,
  npins,
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

    home.packages = [
      pkgs.twm
    ];

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
            set cmd " ${pkgs.eza}/bin/eza && git status -sb"
          else
            set cmd " ${pkgs.eza}/bin/eza"
          end
          echo $cmd
        '';
        enter_ls = ''
          set -l cmd (commandline)
          if test -z "$cmd"
            commandline -r (magic_enter_cmd)
            commandline -f suppress-autosuggestion
          end
          commandline -f execute
        '';
        sri = ''
          set filter "$argv"
          set chosen_project (git workspace list | sk -q "$filter")
          if string length -q -- $chosen_project
            ${pkgs.twm}/bin/twm -p $GIT_WORKSPACE/$chosen_project
          end
        '';
        pri = ''
          set filter "$argv"
          set chosen_project (git workspace list | sk -q "$filter")
          if string length -q -- $chosen_project
            pushd $GIT_WORKSPACE/$chosen_project
          end
        '';
        prepend_command = ''
          set -l prepend $argv[1]
          if test -z "$prepend"
            echo "prepend_command needs one argument."
            return 1
          end

          set -l cmd (commandline)
          if test -z "$cmd"
            commandline -r $history[1]
          end

          set -l old_cursor (commandline -C)
          commandline -C 0
          commandline -i "$prepend "
          commandline -C (math $old_cursor + (echo $prepend | wc -c))
        '';

        ya = ''
          set tmp (mktemp -t "yazi-cwd.XXXXX")
          ${pkgs.yazi}/bin/yazi $argv --cwd-file="$tmp"
          if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
              cd -- "$cwd"
          end
          rm -f -- "$tmp"
        '';
      };

      plugins = [
        {
          name = "pisces";
          src = npins.pisces;
        }
      ];

      interactiveShellInit =
        ''
          if test (uname) = Darwin
            fish_add_path --prepend --global /run/current-system/sw/bin "/etc/profiles/per-user/$USER/bin"
            fish_add_path --append --global /nix/var/nix/profiles/default/bin
          end

          set -U fish_greeting
          bind \t 'commandline -f complete'
          bind \e 'commandline -f cancel'
          bind \r 'enter_ls'
          bind \n 'enter_ls'
          bind \cs 'prepend_command sudo'

          if bind -M insert >/dev/null 2>&1
            bind -M insert \t 'commandline -f complete'
            bind -M insert \e 'commandline -f cancel'
            bind -M insert \r 'enter_ls'
            bind -M insert \n 'enter_ls'
          end
        ''
        + (lib.optionalString (config.phil.terminals.multiplexer == "tmux") ''
          if status is-interactive
          and not status --is-login
          and not set -q TMUX
          and not set -q NVIM
          and set -q DISPLAY
            tmux attach || tmux
          end
        '')
        + (lib.optionalString (config.phil.terminals.multiplexer == "zellij") ''
          if status is-interactive
          and not status --is-login
          and not set -q TMUX
          and not set -q NVIM
          and set -q DISPLAY
          and not set -q ZELLIJ
            zellij attach --create main
          end
        '')
        + (lib.optionalString (config.phil.gpg.enable && lib.hasInfix "darwin" pkgs.system) ''
          set -Ux GPG_TTY (tty)
          set -e SSH_AUTH_SOCK
          set -Ux SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
          gpgconf --launch gpg-agent
        '');
    };
  };
}
