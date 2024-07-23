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
    phil.twm = {
      enable = true;
      settings = {
        search_paths = ["~"];

        workspace_definitions = [
          {
            name = "default";
            has_any_file = [".git" ".twm.yaml"];
            default_layout = "default";
          }
        ];

        layouts = [
          {
            name = "default";
            commands = [];
          }
        ];
      };
    };

    programs.tmux = {
      enable = true;
      baseIndex = 1;
      escapeTime = 1;
      keyMode = "vi";
      secureSocket = true;
      shortcut = "a";
      mouse = true;
      sensibleOnTop = true;
      shell = "${pkgs.${config.phil.terminals.defaultShell}}/bin/${config.phil.terminals.defaultShell}";
      terminal = "tmux-256color";
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

        bind y 'select-pane -L'
        bind n 'select-pane -D'
        bind e 'select-pane -U'
        bind o 'select-pane -R'

        bind -r C-y select-window -t :-
        bind -r C-o select-window -t :+

        bind-key P run-shell -b "${pkgs.writeShellScript "switch-sessions" ''
          chosen_project=$(git workspace list | ${pkgs.fzf}/bin/fzf-tmux -p)
          if [ ! -z "$chosen_project" ]; then
            ${pkgs.twm}/bin/twm -p $GIT_WORKSPACE/$chosen_project
          fi
        ''}"

        bind -r Y resize-pane -L 5
        bind -r N resize-pane -D 5
        bind -r E resize-pane -U 5
        bind -r O resize-pane -R 5
      '';

      plugins = with pkgs.tmuxPlugins; [
        sessionist
        tmux-fzf
        {
          plugin = catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavour 'mocha'

            set -g @catppuccin_window_left_separator "█"
            set -g @catppuccin_window_right_separator "█ "
            set -g @catppuccin_window_number_position "right"
            set -g @catppuccin_window_middle_separator "  █"

            set -g @catppuccin_window_default_fill "number"
            set -g @catppuccin_window_default_text "#W"

            set -g @catppuccin_window_current_fill "number"
            set -g @catppuccin_window_current_text "#W"

            set -g @catppuccin_status_modules_left "session"
            set -g @catppuccin_status_modules_right "date_time"
            set -g @catppuccin_status_justify "centre"

            set -g @catppuccin_status_left_separator "█"
            set -g @catppuccin_status_right_separator "█"
            set -g @catppuccin_status_background "default"

            set -g @catppuccin_status_fill "icon"
            set -g @catppuccin_status_connect_separator "yes"
          '';
        }
        {
          plugin = resurrect; # Used by tmux-continuum
          extraConfig = ''
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-pane-contents-area 'visible'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5' # minutes
          '';
        }
        {
          plugin = tmux-thumbs;
          extraConfig = ''
            set -g @thumbs-key T
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
