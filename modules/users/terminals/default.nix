{ pkgs
, config
, inputs
, lib
, ...
}:

let
  inherit (lib) mkOption types mkIf;
  cfg = config.phil.terminals;
in
{
  options.phil.terminals = {
    default_font = mkOption {
      description = "default font";
      type = types.str;
      default = "Iosevka Comfy";
    };

    multiplexer = mkOption {
      type = types.enum [ "tmux" "zellij" ];
      default = "tmux";
    };
  };

  config = {
    programs = {
      alacritty = {
        enable = true;
        settings = {
          decorations = "none";
          padding = {
            x = 15;
            y = 15;
          };
          window.opacity = 0.55;
          font.size = 13;
        };
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

      foot = {
        enable = true;
        server.enable = true;

        settings = {
          main = {
            font = "${cfg.default_font}:size=13";
            bold-text-in-bright = "yes";
            dpi-aware = "yes";
          };
          url = {
            launch = "firefox \${url}";
            osc8-underline = "always";
          };
        };
      };
    };
  };
}
