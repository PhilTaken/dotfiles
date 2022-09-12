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

  config = mkIf cfg.enable {
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
          # dont run tmux in nvim shells, in zellij splits or when display isn't set
          PPNAME="$(ps -o comm= -p $PPID)"
          if [[ ! "$PPNAME" == "nvim" ]] && [[ $DISPLAY ]]; then
            [[ $- != *i* ]] && return
            if [[ -z "$TMUX" ]] && [[ -z "$ZELLIJ" ]]; then
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
      };
  };
}
