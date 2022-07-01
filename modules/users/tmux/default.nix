{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.tmux;
in
rec {
  options.phil.tmux = {
    enable = mkEnableOption "tmux";
    defaultShell = mkOption {
      type = types.enum [ "fish" "zsh" ];
      default = "zsh";
    };
  };

  config = mkIf (cfg.enable) {
    programs.tmux =
      let
        #airline_conf = ./tmux_airline.conf;
        #colorscheme_conf = ./catppuccino_dark.conf;
        catppuccin_tmux_conf = ./catppuccin.conf;
        #colorscheme_conf = "${inputs.inputs.tmux-colorscheme}/catppuccin.conf";
      in
      {
        # TODO: tmuxp configs
        tmuxp.enable = true;
        enable = true;
        baseIndex = 1;
        escapeTime = 1;
        keyMode = "vi";
        secureSocket = true;
        shortcut = "a";
        shell = "${pkgs.${cfg.defaultShell}}/bin/${cfg.defaultShell}";
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

          # --------------------------

          source ${catppuccin_tmux_conf}
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
}
