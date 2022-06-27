# vi: ft=nix
{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.shells.zsh;
  magic_enter_prompt = ./magic_enter.zsh;
in
rec {
  options.phil.shells.zsh = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    programs.zsh =
      {
        enable = true;
        enableAutosuggestions = true;
        enableCompletion = true;
        autocd = true;
        defaultKeymap = "viins";
        dotDir = ".config/zsh";

        history = {
          ignoreDups = true;
          ignoreSpace = true;
          share = true;
          path = "${inputs.config.xdg.dataHome}/zsh/histfile";
        };

        initExtraBeforeCompInit = ''
          setopt prompt_subst
          setopt prompt_sp
          setopt always_to_end
          setopt complete_in_word
          setopt hist_verify

          setopt extended_glob
          setopt nomatch

          setopt complete_aliases
          setopt mark_dirs
          setopt bang_hist
          setopt extended_history

          setopt interactive_comments
          setopt auto_continue
          setopt pipefail

          unsetopt beep notify clobber
        '';

        initExtra = ''
          autoload -Uz zmv
          autoload -Uz zed

          zle_highlight=(iserach:underline)

          zstyle ':completion:*' special-dirs true
          zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,comm'

          zstyle ':completion:*' completer _complete _match _approximate
          zstyle ':completion:*:match:*' original only
          zstyle ':completion:*:approximate:*' max-errors 10 numeric

          WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

          eval "$(${pkgs.fasd}/bin/fasd --init auto)"
          #unalias z

          source ${magic_enter_prompt}

          loc() {
              nix-locate $1 | ${pkgs.choose}/bin/choose 0 | sort | uniq
          }

          flakify() {
            if [ ! -e flake.nix ]; then
              nix flake new -t github:nix-community/nix-direnv .
              direnv allow
            fi
            if [ ! -e .envrc ]; then
              echo "use flake" > .envrc
              direnv allow
            fi
            if [ ! -e .gitignore ]; then
              echo ".envrc\ntags\n.direnv" > .gitignore
            fi
            ''${EDITOR:-vim} flake.nix
          }
        '' + (lib.optionalString inputs.config.phil.git.enable ''
          cworktree() {
            remote=$1
            dir=$2

            if [ -z "$remote" ]; then
                echo "usage: $0 remote [dir]" && return 1
            fi

            if [ -z "$dir" ]; then
                dir=''$(basename -s .git "$remote")
            fi

            mkdir "$dir"
            pushd "$dir"
            git clone --bare "$remote" .bare
            echo "gitdir: ./.bare" > .git
            git worktree add main
            popd
          }
        '') + (lib.optionalString inputs.config.phil.tmux.enable ''
          # dont run tmux in nvim shells or when display isn't set
          PPNAME="$(ps -o comm= -p $PPID)"
          if [[ ! "$PPNAME" == "nvim" ]] && [[ $DISPLAY ]]; then
            [[ $- != *i* ]] && return
            if [[ -z "$TMUX" ]]; then
              ID="$(${pkgs.tmux}/bin/tmux ls | grep -vm1 attached | cut -d: -f1)"
              if [[ -z "$ID" ]]; then
                ${pkgs.tmux}/bin/tmux new-session
              else
                ${pkgs.tmux}/bin/tmux attach-session -t "$ID"
              fi
            fi
          fi

          if [ -n "$TMUX" ]; then
            eval "$(tmux show-environment -s NVIM_LISTEN_ADDRESS)"
          else
            export NVIM_LISTEN_ADDRESS=/tmp/nvimsocket
          fi
        '');

        shellGlobalAliases = {
          "%notif" = "&& notify-send 'done' || notify-send 'error'";
        };

        shellAliases = rec {
          sudo = "sudo ";
          gre = "${pkgs.ripgrep}/bin/rg";
          df = "df -h";
          free = "${pkgs.procps}/bin/free -h";
          exal = "${pkgs.exa}/bin/exa -liaahmF --git --group-directories-first";
          ll = exal;
          exa = "${pkgs.exa}/bin/exa -Fx --group-directories-first";
          cat = "${pkgs.bat}/bin/bat";
          ntop = "sudo ntop -u nobody";

          top = "${pkgs.bottom}/bin/btm";
          du = "${pkgs.du-dust}/bin/dust";
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
          flkup = "nix flake update --commit-lock-file";
          lg = "${pkgs.lazygit}/bin/lazygit";
        });
      };
  };
}
