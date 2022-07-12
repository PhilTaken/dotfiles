{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.shells.fish;
in
rec {
  options.phil.shells.fish = {
    enable = mkEnableOption "fish";
  };

  config = mkIf (cfg.enable) {
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
            set cmd "${pkgs.exa}/bin/exa && git status -sb"
          else
            set cmd "${pkgs.exa}/bin/exa"
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
            _atuin_unsuppress_tui
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
        bind \t 'commandline -f complete && _atuin_suppress_tui'
        bind \e 'commandline -f cancel && _atuin_unsuppress_tui'
        bind \r 'enter_ls && _atuin_unsuppress_tui'
        bind \n 'enter_ls && _atuin_unsuppress_tui'

        if bind -M insert >/dev/null 2>&1
          bind -M insert \cr _atuin_search
          bind -M insert \t 'commandline -f complete && _atuin_suppress_tui'
          bind -M insert \e 'commandline -f cancel && _atuin_unsuppress_tui'
          bind -M insert \r 'enter_ls'
          bind -M insert \n 'enter_ls'
        end
      '';

      shellAliases = rec {
        zj = "${pkgs.zellij}/bin/zellij";
        gre = "${pkgs.ripgrep}/bin/rg";
        cat = "${pkgs.bat}/bin/bat";
        top = "${pkgs.bottom}/bin/btm";
        du = "${pkgs.du-dust}/bin/dust";
        free = "${pkgs.procps}/bin/free -h";
        sudo = "sudo ";
        df = "df -h";
        exal = "${pkgs.exa}/bin/exa -liaahmF --git --group-directories-first";
        ll = exal;
        exa = "${pkgs.exa}/bin/exa -Fx --group-directories-first";
        ntop = "sudo ntop -u nobody";
        dmesg = "dmesg -H";
        # c/c++ dev
        bear = "${pkgs.bear}/bin/bear";
      } // (lib.optionalAttrs inputs.config.wayland.windowManager.sway.enable {
        sockfix = "export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway).sock";
      }) // (lib.optionalAttrs inputs.config.programs.git.enable {
        # git
        ga = "${pkgs.git}/bin/git add";
        gc = "${pkgs.git}/bin/git commit";
        gd = "${pkgs.git}/bin/git diff";
        gr = "${pkgs.git}/bin/git reset";
        grv = "${pkgs.git}/bin/git remote -v";
        gl = "${pkgs.git}/bin/git pull";
        gp = "${pkgs.git}/bin/git push";
        glog = "${pkgs.git}/bin/git log";
        gco = "${pkgs.git}/bin/git checkout";
        gcm = "${pkgs.git}/bin/git checkout main";
        lg = "${pkgs.lazygit}/bin/lazygit";
        flkup = "nix flake update --commit-lock-file";
      });
    };
  };
}
