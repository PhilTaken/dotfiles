{
  pkgs,
  username,
  ...
}: let
  lock_bg = ../.. + "/${username}/wallpaper/lock.jpg";
in rec {
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
    enableNixDirenvIntegration = true;
    enableZshIntegration = true;
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

  programs.zsh = let
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
    '';
    shellGlobalAliases = {
      "%notif" = "&& notify-send 'done' || notify-send 'error'";
    };
    shellAliases = {
      sudo = "sudo ";
      gre = "rg";
      df = "df -h";
      free = "free -h";
      exal = "command exa -liaahmF --git --group-directories-first";
      exa = "command exa -Fx --group-directories-first";
      ll = "exal";
      cat = "bat";
      ntop = "sudo ntop -u nobody";
      open = "xdg-open";
      pass = "gopass";
      yta = "youtube-dl -x --audio-format flac";
      vo = "f -fe zathura";
      sockfix = "export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway).sock";
      top = "btm";
      lock = "swaylock -i ${lock_bg}";
      du="dust";

      # c/c++ dev
      bear = "nix-shell -p bear --run bear";

      # wget
      wget = "nix-shell -p wget --run wget";

      # git
      ga="git add";
      gc="git commit";
      gd="git diff";
      gr="git reset";
      grv="git remote -v";
      gl="git pull";
      gp="git push";
      glog="git log";
      gco="git checkout";
      gcm="git checkout main";
      flkup="nix flake update --commit-lock-file";
    };
  };

  programs.tmux = let
    airline_conf = ./tmux_airline.conf;
  in {
    enable = true;
    baseIndex = 1;
    escapeTime = 1;
    keyMode = "vi";
    secureSocket = true;
    shortcut = "a";
    terminal = "screen-256color";
    extraConfig = ''
        source ${airline_conf}

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

        bind y select-pane -L
        bind n select-pane -D
        bind e select-pane -U
        bind o select-pane -R

        bind -r C-y select-window -t :-
        bind -r C-o select-window -t :+

        bind -r Y resize-pane -L 5
        bind -r N resize-pane -D 5
        bind -r E resize-pane -U 5
        bind -r O resize-pane -R 5
    '';
  };

  xdg.configFile."page/init.vim".source = ./page.vim;
  #xdg.configFile."direnv/direnvrc".source = ./direnvrc;

  home.packages = with pkgs; [
    page
    bandwhich
    bottom
    du-dust
    exa
    fasd
    fd
    file
    fortune
    lolcat
    lshw
    neofetch
    procs
    ripgrep
    ripgrep-all
    rsync
    sd
    sshfs
    unzip
  ];


}
