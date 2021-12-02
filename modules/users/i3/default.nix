# TODO: polybar colors
# TODO: polybar modules separation / icons
{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.i3;
in
rec
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
      default = "Iosevka Nerd Font";
    };
  };

  config = mkIf (cfg.enable) rec {
    xsession.windowManager.i3 = rec {
      enable = true;
      package = cfg.package;
      config = {
        #assigns = {
        #"1: Terminal" = [{ class = "alacritty"; }];
        #"2: Web" = [{ class = "^Firefox$"; }];
        #"4: Spotify" = [{ class = "Spotify"; }];
        #};
        floating = {
          border = 0;
          criteria = [
            { title = "Steam - Update News"; }
            { class = "Pavucontrol"; }
          ];
        };
        gaps = {
          inner = 12;
          outer = 0;
          top = 25;
          smartBorders = "on";
        };
        bars = [ ];
        startup = [
          { command = "${pkgs.feh}/bin/feh --bg-scale ${cfg.bg}"; always = true; notification = false; }
          { command = "systemctl --user restart polybar.service"; always = true; }
        ];
        keybindings =
          let
            modifier = config.modifier;
            terminal = "${programs.alacritty.package}/bin/alacritty";
          in
          {
            "${modifier}+Return" = "exec ${terminal}";
            "${modifier}+d" = "kill";
            "${modifier}+space" = "exec ${pkgs.rofi}/bin/rofi -show run";
            "${modifier}+l" = "exec ${pkgs.i3lock-pixeled}/bin/i3lock-pixeled";
            "${modifier}+q" = "exec ${pkgs.flameshot}/bin/flameshot gui";
            "${modifier}+p" = "exec ${pkgs.rofi-pass}/bin/rofi-pass";

            "${modifier}+y" = "focus left";
            "${modifier}+n" = "focus down";
            "${modifier}+e" = "focus up";
            "${modifier}+o" = "focus right";

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
          font.normal.family = cfg.terminal_font;
          font.size = 12;
        };
      };
    };

    services.picom = {
      enable = true;
      activeOpacity = "0.98";
      opacityRule = [
        "100:class_g ?= 'Firefox'"
      ];
      blur = true;
      blurExclude = [
        "class_g = 'slop'"
        "class_i = 'polybar'"
        "class_i = 'rofi'"
        "class_g = 'rofi'"
      ];
      fade = true;
      fadeDelta = 8;
      inactiveDim = "0.1";
      inactiveOpacity = "0.9";
      shadow = true;
    };

    services.polybar = {
      enable = true;
      package = pkgs.polybar.override {
        i3GapsSupport = true;
        githubSupport = true;
        pulseSupport = true;
      };
      config = {
        "bar/base" = {
          width = "100%:-24";
          height = "32";

          offset-x = "12";
          offset-y = "5";

          override-redirect = true;
          wm-restack = "i3";

          radius = "10";
          bottom = "false";

          padding = "1";

          fixed-center = "true";

          font-N = "<fontconfig pattern>;<vertical offset>";
          font-0 = "Iosevka;2";

          modules-left = "workspaces";
          modules-center = "date";
          modules-right = "volume network cpu ram";
        };

        "module/network" = {
          type = "internal/network";
          interface = "enp0s25";
          ping-interval = "3";
        };

        "module/date" = {
          type = "internal/date";
          interval = "1.0";
          time = "%I:%M %p";
          label = "%time%";

          format = "<label>";
          format-padding = "0";
          label-padding = "4";
        };

        "module/volume" = {
          type = "internal/pulseaudio";
          format-volume = "<label-volume>  ";

          label-volume = "%percentage%%";
          label-volume-padding = "1";

          format-muted = "<label-muted>";

          label-muted = "0% (muted)";
          label-muted-padding = "1";

          format-volume-padding = "0";
          format-muted-padding = "0";
          ramp-headphones-0 = " ";
        };


        "module/cpu" = {
          type = "internal/cpu";
          interval = "0.5";
          format = "<label>";
          label = "%percentage%%";
          label-padding = "1";
          format-prefix-padding = "1";
        };

        "module/ram" = {
          type = "internal/memory";
          interval = "3";

          format = "<label>";
          label = "%percentage_used%%";
          label-padding = "1";
          format-prefix-padding = "1";
        };

        "module/workspaces" = {
          type = "internal/i3";
          format = "<label-state> <label-mode>";
          index-sort = "true";
          wrapping-scroll = "false";
          strip-wsnumbers = "true";
          pin-workspaces = "true";
        };
      };
      script = "polybar base &";
    };

    services.pulseeffects = {
      enable = false;
      package = pkgs.pulseeffects-legacy;
    };

    systemd.user.services.flameshot = {
      Unit = {
        Description = "Unit for the flameshot daemon";
        After = "graphical-session-pre.target";
        PartOf = "graphical-session.target";
      };

      Service = {
        ExecStart = "${pkgs.flameshot}/bin/flameshot";
        Restart = "on-abort";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };


    home.packages = with pkgs; [
      flameshot
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

      #rofi-pass
    ];
  };
}
