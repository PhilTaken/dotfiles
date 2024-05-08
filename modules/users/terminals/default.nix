{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.phil.terminals;
in {
  options.phil.terminals = {
    default_font = mkOption {
      description = "default font";
      type = types.str;
      #default = "Iosevka Comfy";
      default = "Victor Mono";
    };

    multiplexer = mkOption {
      type = types.enum ["tmux" "zellij"];
      default = "zellij";
    };

    defaultShell = mkOption {
      type = types.enum ["fish" "zsh" "nushell"];
      default = "fish";
    };

    alacritty = {
      decorations = mkOption {
        type = types.enum ["none" "full"];
        default = "none";
      };
    };
  };

  config = lib.mkIf (!config.phil.headless) {
    programs = {
      alacritty = {
        enable = false;
        settings = {
          window = {
            padding = {
              x = 5;
              y = 5;
            };
            inherit (cfg.alacritty) decorations;
          };
        };
      };

      kitty = {
        enable = true;
      };

      wezterm = {
        enable = true;
        # TODO make color_scheme configurable
        extraConfig = ''
          local config = {
            window_padding = { left = 5, right = 5, top = 5, bottom = 5 },
            hide_tab_bar_if_only_one_tab = true,
            font_size = 11.0,
            dpi = 192.0,
            adjust_window_size_when_changing_font_size = false,
            window_background_opacity = 0.90,
            macos_window_background_blur = 20,
            warn_about_missing_glyphs = false,
          }

          config.hyperlink_rules = wezterm.default_hyperlink_rules()

          table.insert(config.hyperlink_rules, {
            regex = [[\b(FC-\d+)\b]],
            format = 'https://yt.flyingcircus.io/issue/$1',
          })

          return config
        '';
      };

      foot = rec {
        enable = ! lib.hasInfix "darwin" pkgs.system;
        server = {inherit enable;};

        settings = {
          main.bold-text-in-bright = "yes";
          url = {
            launch = "firefox \${url}";
            osc8-underline = "always";
          };
        };
      };
    };
  };
}
