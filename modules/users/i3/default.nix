{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.i3;
in
{
  options.phil.i3 = {
    enable = mkOption {
      description = "Enable i3";
      type = types.bool;
      default = false;
    };

    package = mkOption {
      description = "i3 package to use";
      type = types.package;
      default = pkgs.i3-gaps;
    };

    lock_bg = mkOption {
      description = "Lock background";
      type = types.nullOr types.path;
      default = null;
    };

    bg = mkOption {
      description = "Main background";
      type = types.nullOr types.path;
      default = null;
    };

    terminal_font = mkOption {
      description = "Font Familiy for the terminal";
    };
  };

  config = mkIf (cfg.enable) {
    xsession.windowManager.i3 = {
      enable = true;
      package = cfg.package;
      config = {
        assigns = {
          "1: Terminal" = [{ class = "alacritty"; }];
          "2: Web" = [{ class = "^Firefox$"; }];
          "4: Spotify" = [{ class = "Spotify"; }];
        };
        floating = {
          border = 0;
          criteria = [{ title = "Steam - Update News"; } { class = "Pavucontrol"; }];
        };
        gaps = {
          inner = 12;
          outer = 0;
          smartBorders = "on";
        };
        keybindings =
          let
            modifier = xsession.windowManager.i3.config.modifier;
            terminal = "${programs.alacritty.package}/bin/alacritty";
          in
          {
            "${modifier}+Return" = "exec ${terminal}";
            "${modifier}+d" = "kill";
            "${modifier}+space" = "exec ${pkgs.rofi}/bin/rofi -show run";
            "${modifier}+l" = "exec ${pkgs.i3lock-pixeled}/bin/i3lock-pixeled";
            "${modifier}+q" = "exec ${pkgs.flameshot}/bin/flameshot gui";
            "${modifier}+p" = "exec ${pkgs.rofi-pass}/bin/rofi-pass";

            "${modifier}+1" = "workspace number 1";
            "${modifier}+2" = "workspace number 2";
            "${modifier}+3" = "workspace number 3";
            "${modifier}+4" = "workspace number 4";
            "${modifier}+5" = "workspace number 5";
            "${modifier}+6" = "workspace number 6";
            "${modifier}+7" = "workspace number 7";
            "${modifier}+8" = "workspace number 8";
            "${modifier}+9" = "workspace number 9";
            "${modifier}+0" = "workspace number 10";

            "${modifier}+Shift+1" = "move container to workspace number 1";
            "${modifier}+Shift+2" = "move container to workspace number 2";
            "${modifier}+Shift+3" = "move container to workspace number 3";
            "${modifier}+Shift+4" = "move container to workspace number 4";
            "${modifier}+Shift+5" = "move container to workspace number 5";
            "${modifier}+Shift+6" = "move container to workspace number 6";
            "${modifier}+Shift+7" = "move container to workspace number 7";
            "${modifier}+Shift+8" = "move container to workspace number 8";
            "${modifier}+Shift+9" = "move container to workspace number 9";
            "${modifier}+Shift+0" = "move container to workspace number 1";
          };
        terminal = "alacritty";
        modifier = "Mod4";
        window.border = 0;
        window.titlebar = false;
      };
    };

    programs = {
      rofi = {
        enable = true;
        package = pkgs.rofi;
      };
      alacritty = {
        enable = true;
        package = pkgs.alacritty;
        settings = {
          font.normal.family = "Iosevka Nerd Font";
          font.size = 12;
        };
      };
    };

    services.picom = {
      enable = true;
      activeOpacity = "0.95";
      blur = true;
      blurExclude = [
        "class_g = 'slop'"
        "class_i = 'polybar'"
        "class_i = 'rofi'"
      ];
      fade = true;
      inactiveDim = "0.15";
      inactiveOpacity = "0.8";
      shadow = true;
    };

    services.polybar = {
      enable = false;
      package = pkgs.polybar.override {
        i3GapsSupport = true;
        githubSupport = true;
      };
      config = {
        "bar/top" = {
          width = "100%";
          height = "3%";
          radius = 0;
          modules-center = "date";
        };

        "module/date" = {
          type = "internal/date";
          internal = 5;
          date = "%d.%m.%y";
          time = "%H:%M";
          label = "%time%  %date%";
        };
      };
      script = "polybar bar &";
    };

    services.pulseeffects = {
      enable = false;
      package = pkgs.pulseeffects-legacy;
    };

    home.packages = with pkgs; [
      feh
      xorg.xauth
      xdotool
      libnotify
      libappindicator
      glibcLocales

      i3status
      i3lock-pixeled
      i3blocks
      flameshot

      xclip

      rofi-pass
    ];
  };
}
