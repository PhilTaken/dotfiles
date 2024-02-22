{
  pkgs,
  config,
  npins,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types;
  cfg = config.phil.tmux;
in {
  options.phil.tmux = {
    enable = mkOption {
      description = "tmux";
      type = lib.types.bool;
      default = config.phil.terminals.multiplexer == "tmux";
    };
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      escapeTime = 1;
      keyMode = "vi";
      secureSocket = true;
      shortcut = "a";
      shell = "${pkgs.${config.phil.terminals.defaultShell}}/bin/${config.phil.terminals.defaultShell}";
      terminal = "xterm-256color";
      extraConfig = ''
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

        # tmux-thumbs trigger

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
      # source {airline_conf}
      # source {colorscheme_conf}

      plugins = with pkgs.tmuxPlugins; [
        sessionist
        {
          plugin = tmux-thumbs;
          extraConfig = ''
            set -g @thumbs-key F
            set -g @thumbs-contrast 1
            set -g @thumbs-unique enabled
          '';
        }
        (mkTmuxPlugin {
          pluginName = "nvr";
          version = "latest";
          src = npins.tmux-nvr;
        })
      ];
    };
  };
}
