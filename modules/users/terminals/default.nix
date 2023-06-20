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
      default = "Iosevka Comfy";
    };

    multiplexer = mkOption {
      type = types.enum ["tmux" "zellij"];
      default = "tmux";
    };

    defaultShell = mkOption {
      type = types.enum ["fish" "zsh"];
      default = "zsh";
    };

    alacritty = {
      decorations = mkOption {
        type = types.enum ["none" "full"];
        default = "full";
      };
    };
  };

  config = {
    programs = {
      alacritty = {
        enable = true;
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
        extraConfig = ''
          return {
            window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
            hide_tab_bar_if_only_one_tab = true,
            color_scheme = "Catppuccin Mocha",
            font = wezterm.font("${cfg.default_font}"),
            font_size = 11.0,
            dpi = 192.0,
            -- front_end = "WebGpu",
          }
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
