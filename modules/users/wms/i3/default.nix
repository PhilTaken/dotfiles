{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.wms.i3;
  barcommand = inputs.config.phil.wms.bars.barcommand;
in rec {
  options.phil.wms.i3 = {
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
      type = types.path;
      default = ../../../../images/cat-sound.png;
    };

    terminal_font = mkOption {
      description = "Font Familiy for the terminal";
      type = types.str;
      default = "Iosevka Nerd Font";
    };

    barcommand = mkOption {
      description = "command to reload the bar";
      type = types.str;
      default = "";
    };
  };

  config = mkIf (cfg.enable) rec {
    phil.wms.tools.udiskie.enable = true;
    services.kdeconnect = {
      enable = true;
      indicator = true;
    };

    xsession.windowManager.i3 = rec {
      enable = true;
      package = cfg.package;
      config = {
        floating = {
          border = 0;
          criteria = [
            { title = "Steam - Update News"; }
            { class = "Pavucontrol"; }
            { class = ".blueman-manager-wrapped"; }
          ];
        };
        gaps = {
          inner = 12;
          #outer = 0;
          #top = 25;
          smartBorders = "on";
        };
        bars = [ ];
        startup = [
          { command = "${pkgs.feh}/bin/feh --bg-scale ${cfg.bg}"; always = true; notification = false; }
        ] ++ (lib.optional (barcommand != "") { command = "\"${barcommand}\""; always = true; });

        keybindings = let
          modifier = config.modifier;
          terminal = "${programs.alacritty.package}/bin/alacritty";
        in {
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

          "${modifier}+Shift+y" = "move container left";
          "${modifier}+Shift+n" = "move container down";
          "${modifier}+Shift+e" = "move container up";
          "${modifier}+Shift+o" = "move container right";

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
          "${modifier}+Shift+0" = "move container to workspace number 10";

          "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioPause" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
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
          env.TERM = "xterm-256color";
        };
      };
    };

    services.picom = {
      enable = true;
      activeOpacity = "0.985";
      inactiveOpacity = "0.96";
      opacityRule = [
        "100:class_g ?= 'Firefox'"
        "100:class_g ?= 'librewolf'"
        "100:class_g ?= 'Google-chrome'"
      ];
      blur = true;
      experimentalBackends = true;
      blurExclude = [
        "class_g = 'slop'"
        "class_i = 'polybar'"
        "class_i = 'rofi'"
        "class_g = 'rofi'"
      ];
      fade = true;
      fadeDelta = 8;
      inactiveDim = "0.1";
      shadow = true;
      extraOptions = ''
        frame-opacity = 1;
        blur-background = true;
        blur-kern = "11x11gaussian";
        blur-background-exclude = [];
      '';
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
