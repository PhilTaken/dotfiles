{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.zsh_full;

  # Automatically download the latest index from Mic92's nix-index-database.
  nix-locate = pkgs.writeShellScriptBin "nix-locate" ''
    set -euo pipefail
    mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index
    # Check for updates at most once a day
    if [ ! -f last-check ] || [ $(find last-check -mtime +1) ]; then
      filename="index-x86_64-$(uname | tr A-Z a-z)"
      # Delete partial downloads
      [ -f files ] || rm -f $filename
      wget -q -N --show-progress \
        https://github.com/Mic92/nix-index-database/releases/latest/download/$filename
      ln -f $filename files
      touch last-check
    fi
    exec ${pkgs.nix-index}/bin/nix-locate "$@"
  '';

  # Modified version of command-not-found.sh that uses our wrapped version of
  # nix-locate, makes the output a bit less noisy, and adds color!
  command-not-found = pkgs.runCommandLocal "command-not-found.sh" { } ''
    mkdir -p $out/etc/profile.d
    substitute ${./command-not-found.sh}                  \
      $out/etc/profile.d/command-not-found.sh             \
      --replace @nix-locate@ ${nix-locate}/bin/nix-locate \
      --replace @tput@ ${pkgs.ncurses}/bin/tput
  '';

in rec {
  options.phil.zsh_full = {
    enable = mkOption {
      description = "enable the zsh module";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    home.sessionVariables = {
      _FASD_DATA = "${inputs.config.xdg.dataHome}/fasd/fasd.data";
      _Z_DATA = "${inputs.config.xdg.dataHome}/fasd/z.data";
      _ZO_ECHO = 1;
    };

    programs = {
      htop.enable = true;
      bat.enable = true;

      nix-index = {
        enable = true;
        enableZshIntegration = true;
        package = pkgs.symlinkJoin {
          name = "nix-index";
          # Don't provide 'bin/nix-index', since the index is updated automatically
          # and it is easy to forget that. It can always be run manually with
          # 'nix run nixpkgs#nix-index' if necessary.
          paths = [ nix-locate command-not-found ];
        };
      };

      password-store = {
        enable = true;
        package = pkgs.gopass;
      };

      skim = {
        enable = true;
        enableZshIntegration = true;
      };

      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
      man = {
        enable = true;
        generateCaches = false;
      };
      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
      starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          add_newline = false;
          character = {
            vicmd_symbol = "λ ·";
            success_symbol = "λ ❱";
            error_symbol = "Ψ ❱";
            #use_symbol_for_status = true;
          };
          package.disabled = true;
          python.symbol = "Py";
          rust.symbol = "R";
          nix_shell = {
            symbol = "❄️ ";
            style = "bold blue";
            format = "[$symbol]($style) ";
          };
          git_status = {
            conflicted = "=";
            ahead = "⇡";
            behind = "⇣";
            diverged = "⇕";
            untracked = "?";
            stashed = "$";
            modified = "!";
            staged = "+";
            renamed = "»";
            deleted = "✘";
          };
          jobs.symbol = "+";
        };
      };

      zsh = let
        magic_enter_prompt = ./magic_enter.zsh;
      in {
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
          unalias z

          source ${magic_enter_prompt}

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

          if [ -n "$TMUX" ]; then
            eval "$(tmux show-environment -s NVIM_LISTEN_ADDRESS)"
          else
            export NVIM_LISTEN_ADDRESS=/tmp/nvimsocket
          fi
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

      tmux = let
        #airline_conf = ./tmux_airline.conf;
        #colorscheme_conf = ./catppuccino_dark.conf;
        catppuccin_tmux_conf = ./catppuccin.conf;
        #colorscheme_conf = "${inputs.inputs.tmux-colorscheme}/catppuccin.conf";
      in {
        enable = true;
        baseIndex = 1;
        escapeTime = 1;
        keyMode = "vi";
        secureSocket = true;
        shortcut = "a";
        #terminal = "screen-256color";
        extraConfig = ''
          set -g default-terminal "xterm-256color"
          set-option -ga terminal-overrides ",xterm-256color:Tc"

          #set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
          #set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

          # --------------------------

          set -g xterm-keys on
          set -s focus-events on

          # setw -g monitor-activity on
          # set -g visual-activity on

          set-window-option -g automatic-rename on
          set-option -g set-titles on
          set -g history-limit 50000
          set -g mouse on
          setw -q -g utf8 on

          # ----------------------

          set -g base-index 1
          setw -g pane-base-index 1
          set -g renumber-windows on
          set -g set-titles on
          set -g status-interval 0


          # ------------------------------------------------------------------------------
          # BINDS

          bind Escape copy-mode
          unbind p
          bind p paste-buffer
          bind-key -T copy-mode-vi 'v' send -X begin-selection
          bind-key -T copy-mode-vi 'y' send -X copy-selection
          bind-key -T copy-mode-vi 'Space' send -X halfpage-down
          bind-key -T copy-mode-vi 'Bspace' send -X halfpage-up

          bind | split-window -h -c '#{pane_current_path}'
          bind - split-window -v -c '#{pane_current_path}'
          unbind '"'
          unbind '%'
          unbind C-a

          is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

          bind y if-shell "$is_vim" 'send-keys M-y' 'select-pane -L'
          bind n if-shell "$is_vim" 'send-keys M-n' 'select-pane -D'
          bind e if-shell "$is_vim" 'send-keys M-e' 'select-pane -U'
          bind o if-shell "$is_vim" 'send-keys M-o' 'select-pane -R'

          bind -r C-y select-window -t :-
          bind -r C-o select-window -t :+

          bind -r Y resize-pane -L 5
          bind -r N resize-pane -D 5
          bind -r E resize-pane -U 5
          bind -r O resize-pane -R 5

          # --------------------------

          source ${catppuccin_tmux_conf}
        '';
        # source {airline_conf}
        # source {colorscheme_conf}

        plugins = with pkgs.tmuxPlugins; [
          sessionist
          (mkTmuxPlugin rec {
            pluginName = "nvr";
            version = "unstable-2021-07-07";
            src = pkgs.fetchFromGitHub {
              owner = "carlocab";
              repo = "tmux-nvr";
              rev = "96a6dae2733cf651ac954306b03263b60d05f26e";
              sha256 = "sha256-lkZZ9xV7m/iTpQpv/YewltyZ+97P2UeSysNdGcCgpAw=";
            };
          })
        ];
      };
    };
    #xdg.configFile."page/init.vim".source = ./page/init.vim;
    #xdg.configFile."direnv/direnvrc".source = ./direnvrc;
    #xdg.configFile."zk/config.toml".source = ./zk/config.toml;
    #xdg.configFile."zk/templates/daily.md".source = ./zk/templates/daily.md;

    home.packages = with pkgs; [
      bandwhich
      cmake
      dig
      exa
      fasd
      fd
      file
      fortune
      gping
      hexyl
      hyperfine
      jq
      lolcat
      lshw
      #magic-wormhole
      nmap
      neofetch
      procs
      ripgrep
      rsync
      sd
      sshfs
      tokei
      tree
      unrar
      unzip
      usbutils
      wget
      yt-dlp
    ];
  };
}
