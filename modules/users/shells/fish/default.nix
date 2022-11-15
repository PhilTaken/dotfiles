{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.shells.fish;
in
{
  options.phil.shells.fish = {
    enable = mkEnableOption "fish";
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;

      functions = {
        gitignore = "curl -sL https://www.gitignore.io/api/$argv";
        license = "curl -sL https://choosealicense.com/licenses/$argv | ${pkgs.pup}/bin/pup -p pre#license-text text{}";
        su = "command su --shell=${pkgs.fish}/bin/fish $argv";
        fix_git_perms = ''
          git diff --summary | grep --color 'mode change 100755 => 100644' | cut -d' ' -f7- | xargs -d'\n' chmod +x 2>/dev/null
          git diff --summary | grep --color 'mode change 100644 => 100755' | cut -d' ' -f7- | xargs -d'\n' chmod -x 2>/dev/null
        '';
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
          src = pkgs.fetchFromGitHub {
            owner = "laughedelic";
            repo = "pisces";
            rev = "e45e0869855d089ba1e628b6248434b2dfa709c4";
            sha256 = "sha256-Oou2IeNNAqR00ZT3bss/DbhrJjGeMsn9dBBYhgdafBw";
          };
        }
      ];

      interactiveShellInit = ''
        set -U fish_greeting
        set -gx ATUIN_NOBIND "true"

        bind \cr _atuin_search
        bind \t 'commandline -f complete'
        bind \e 'commandline -f cancel'
        bind \r 'enter_ls'
        bind \n 'enter_ls'

        if bind -M insert >/dev/null 2>&1
          bind -M insert \cr _atuin_search
          bind -M insert \t 'commandline -f complete'
          bind -M insert \e 'commandline -f cancel'
          bind -M insert \r 'enter_ls'
          bind -M insert \n 'enter_ls'
        end
      '';
    };
  };
}
