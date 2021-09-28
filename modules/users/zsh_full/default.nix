{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.zsh;
in
rec {
  options.phil.zsh = {
    enable = mkOption {
      description = "enable the zsh module";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    programs.password-store = {
      enable = true;
      package = pkgs.gopass;
    };
    programs.skim = {
      enable = true;
      enableZshIntegration = true;
    };
    programs.htop.enable = true;
    programs.bat.enable = true;
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
        enableFlakes = true;
      };
    };
    programs.man = {
      enable = true;
      generateCaches = false;
    };
    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.starship = {
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
        python.symbol = "Py ";
        rust.symbol = "R ";
        nix_shell = {
          symbol = "❄️ ";
          style = "bold blue";
          format = "[$symbol]($style) ";
        };
        git_status = {
          conflicted = "=";
          ahead = "⇡ ";
          behind = "⇣ ";
          diverged = "⇕ ";
          untracked = "?";
          stashed = "$";
          modified = "!";
          staged = "+";
          renamed = "»";
          deleted = "✘ ";
        };
        jobs.symbol = "+";
      };
    };

    programs.zsh =
      let
        magic_enter_prompt = ./magic_enter.zsh;
      in
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
          path = "$XDG_DATA_HOME/zsh/histfile";
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

          eval "$(fasd --init auto)"
          unalias z

          source ${magic_enter_prompt}

          if [[ $DISPLAY ]]; then
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

          flakify() {
            if [ ! -e flake.nix ]; then
              nix flake new -t github:nix-community/nix-direnv .
            fi
            if [ ! -e .envrc ]; then
              echo "use flake" > .envrc
              direnv allow
            fi
            ''${EDITOR:-vim} flake.nix
          }

          if [ -n "$TMUX" ]; then
            eval "$(tmux show-environment -s NVIM_LISTEN_ADDRESS)"
          else
            export NVIM_LISTEN_ADDRESS=/tmp/nvimsocket
          fi
        '';
        shellGlobalAliases = {
          "%notif" = "&& notify-send 'done' || notify-send 'error'";
        };
        shellAliases = {
          sudo = "sudo ";
          gre = "${pkgs.ripgrep}/bin/rg";
          df = "df -h";
          free = "${pkgs.procps}/bin/free -h";
          exal = "${pkgs.exa}/bin/exa -liaahmF --git --group-directories-first";
          exa = "${pkgs.exa}/bin/exa -Fx --group-directories-first";
          ll = "exal";
          cat = "${pkgs.bat}/bin/bat";
          ntop = "sudo ntop -u nobody";
          # TBD
          #open = "xdg-open";
          #pass = "gopass";

          sockfix = "export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway).sock";
          top = "${pkgs.bottom}/bin/btm";
          du = "${pkgs.du-dust}/bin/dust";
          dmesg = "dmesg -H";

          # c/c++ dev
          bear = "${pkgs.bear}/bin/bear";

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
        };
      };

    programs.tmux =
      let
        airline_conf = ./tmux_airline.conf;
      in
      {
        enable = true;
        baseIndex = 1;
        escapeTime = 1;
        keyMode = "vi";
        secureSocket = true;
        shortcut = "a";
        terminal = "screen-256color";
        extraConfig = ''
          source ${airline_conf}

          set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
          set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

          set -g mouse on
          setw -g monitor-activity on
          set -g visual-activity on
          set-option -sa terminal-overrides ',alacritty:Tc'

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
        '';
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

    #xdg.configFile."page/init.vim".source = ./page/init.vim;
    #xdg.configFile."direnv/direnvrc".source = ./direnvrc;
    #xdg.configFile."zk/config.toml".source = ./zk/config.toml;
    #xdg.configFile."zk/templates/daily.md".source = ./zk/templates/daily.md;

    home.packages = with pkgs; [
      bandwhich
      cmake
      dig
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
      magic-wormhole
      ncat
      neofetch
      procs
      rsync
      sd
      sshfs
      tokei
      tree
      unzip
      usbutils
      wget
      yt-dlp
    ];
  };

}
