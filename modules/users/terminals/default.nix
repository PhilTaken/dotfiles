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
      default = "tmux";
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
    home.packages = lib.optionals (lib.hasSuffix "linux" pkgs.system) [pkgs.ghostty];

    programs.foot.enable = false; # lib.hasSuffix "linux" pkgs.system;

    programs = {
      alacritty = {
        enable = true;
        settings = {
          window = {
            padding = {
              x = 5;
              y = 5;
            };
            # inherit (cfg.alacritty) decorations;
          };
        };
      };

      wezterm = {
        enable = true;
        # TODO make color_scheme configurable
        extraConfig = ''
          local wezterm = require 'wezterm'
          local act = wezterm.action

          local config = {}
          if wezterm.config_builder then
            config = wezterm.config_builder()
          end

          config.window_padding = { left = 12, right = 12, top = 16, bottom = 7 }
          config.macos_window_background_blur = 20
          config.hide_tab_bar_if_only_one_tab = true
          config.font_size = 11.0
          config.dpi = 192.0
          config.adjust_window_size_when_changing_font_size = false
          config.warn_about_missing_glyphs = false
          config.disable_default_key_bindings = true
          config.color_scheme = 'Catppuccin Macchiato'
          config.front_end = "WebGpu"

          -- https://github.com/wez/wezterm/issues/5360
          config.enable_wayland = true

          config.keys = {
            { key = ')', mods = 'CTRL', action = act.ResetFontSize },
            { key = ')', mods = 'SHIFT|CTRL', action = act.ResetFontSize },
            { key = '+', mods = 'CTRL', action = act.IncreaseFontSize },
            { key = '+', mods = 'SHIFT|CTRL', action = act.IncreaseFontSize },
            { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
            { key = '-', mods = 'SHIFT|CTRL', action = act.DecreaseFontSize },
            { key = '-', mods = 'SUPER', action = act.DecreaseFontSize },
            { key = '0', mods = 'CTRL', action = act.ResetFontSize },
            { key = '0', mods = 'SHIFT|CTRL', action = act.ResetFontSize },
            { key = '0', mods = 'SUPER', action = act.ResetFontSize },
            { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
            { key = '=', mods = 'SHIFT|CTRL', action = act.IncreaseFontSize },
            { key = '=', mods = 'SUPER', action = act.IncreaseFontSize },
            { key = 'C', mods = 'CTRL', action = act.CopyTo 'Clipboard' },
            { key = 'C', mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
            { key = 'N', mods = 'CTRL', action = act.SpawnWindow },
            { key = 'N', mods = 'SHIFT|CTRL', action = act.SpawnWindow },
            { key = 'P', mods = 'CTRL', action = act.ActivateCommandPalette },
            { key = 'P', mods = 'SHIFT|CTRL', action = act.ActivateCommandPalette },
            { key = 'Q', mods = 'CTRL', action = act.QuitApplication },
            { key = 'Q', mods = 'SHIFT|CTRL', action = act.QuitApplication },
            { key = 'U', mods = 'CTRL', action = act.CharSelect{ copy_on_select = true, copy_to =  'ClipboardAndPrimarySelection' } },
            { key = 'U', mods = 'SHIFT|CTRL', action = act.CharSelect{ copy_on_select = true, copy_to =  'ClipboardAndPrimarySelection' } },
            { key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
            { key = 'V', mods = 'SHIFT|CTRL', action = act.PasteFrom 'Clipboard' },
            { key = '_', mods = 'CTRL', action = act.DecreaseFontSize },
            { key = '_', mods = 'SHIFT|CTRL', action = act.DecreaseFontSize },
            { key = 'c', mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
            { key = 'c', mods = 'SUPER', action = act.CopyTo 'Clipboard' },
            { key = 'l', mods = 'SHIFT|CTRL', action = act.ShowDebugOverlay },
            { key = 'n', mods = 'SHIFT|CTRL', action = act.SpawnWindow },
            { key = 'n', mods = 'SUPER', action = act.SpawnWindow },
            { key = 'p', mods = 'SHIFT|CTRL', action = act.ActivateCommandPalette },
            { key = 'q', mods = 'SHIFT|CTRL', action = act.QuitApplication },
            { key = 'q', mods = 'SUPER', action = act.QuitApplication },
            { key = 'r', mods = 'SHIFT|CTRL', action = act.ReloadConfiguration },
            { key = 'r', mods = 'SUPER', action = act.ReloadConfiguration },
            { key = 'u', mods = 'SHIFT|CTRL', action = act.CharSelect{ copy_on_select = true, copy_to =  'ClipboardAndPrimarySelection' } },
            { key = 'v', mods = 'SHIFT|CTRL', action = act.PasteFrom 'Clipboard' },
            { key = 'v', mods = 'SUPER', action = act.PasteFrom 'Clipboard' },
            { key = 'phys:Space', mods = 'SHIFT|CTRL', action = act.QuickSelect },
            { key = 'Copy', mods = 'NONE', action = act.CopyTo 'Clipboard' },
            { key = 'Paste', mods = 'NONE', action = act.PasteFrom 'Clipboard' },
          }

          config.hyperlink_rules = wezterm.default_hyperlink_rules()

          table.insert(config.hyperlink_rules, {
            regex = [[\b(FC-\d+)\b]],
            format = 'https://yt.flyingcircus.io/issue/$1',
          })

          return config
        '';
      };
    };
  };
}
