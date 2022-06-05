{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.wms.sway;
in
rec {
  options.phil.wms.sway = {
    enable = mkOption {
      description = "Enable the sway module";
      type = types.bool;
      default = false;
    };

    lock_bg = mkOption {
      description = "Locking background";
      type = types.nullOr types.path;
      default = null;
    };

    background_image = mkOption {
      description = "Background image";
      type = types.path;
      default = ../../../../images/nix-wallpaper-dracula.png;
    };
  };

  config = mkIf (cfg.enable) rec {
    home.sessionVariables = {
      XDG_CURRENT_DESKTOP = "sway";
      MOZ_ENABLE_WAYLAND = 1;
    };

    wayland.windowManager.sway = let
      std_opacity = "0.96";
      lock = "swaylock -c 000000";
      screen_recorder = ./record_screen.sh;
    in {
      enable = true;
      config = {
        up = "e";
        down = "n";
        left = "y";
        right = "o";
        modifier = "Mod4";
        terminal = "${pkgs.foot}/bin/foot";
        #terminal = "${pkgs.alacritty}/bin/alacritty";
        menu = "rofi -show run";
        floating.border = 0;
        focus.followMouse = "always";
        bindkeysToCode = false;
        bars = [ ];
        gaps = {
          inner = 12;
          outer = 0;
          smartBorders = "on";
        };
        input = {
          # integrated keyboard
          "1:1:AT_Translated_Set_2_keyboard" = {
            xkb_layout = "us(workman-intl),us(intl)";
            xkb_options = "caps:escape,grp:shifts_toggle";
          };
          # office keyboard
          "1241:36:HOLDCHIP_USB_Gaming_Keyboard" = {
            xkb_layout = "us(workman-intl)";
            xkb_options = "caps:escape,altwin:swap_alt_win";
          };
          # office planck
          "936:42233:OLKB_Planck" = {
            xkb_layout = "us(intl)";
          };
          # all other keyboard
          "*" = {
            xkb_layout = "us(workman-intl)";
            xkb_options = "caps:escape";
          };
        };
        keybindings =
          let
            swayconf = wayland.windowManager.sway.config;
            term = swayconf.terminal;
            mod = swayconf.modifier;
            menu = swayconf.menu;
            up = swayconf.up;
            down = swayconf.down;
            left = swayconf.left;
            right = swayconf.right;
          in
          {
            "${mod}+Shift+c" = "reload";
            "${mod}+Shift+u" = "exit";
            "${mod}+Return" = "exec ${term}";
            "${mod}+q" = "exec ${pkgs.flameshot}/bin/flameshot gui";
            "${mod}+d" = "kill";
            "${mod}+Space" = "exec ${menu}";
            "${mod}+p" = "exec gopass-rofi";
            "${mod}+u" = "exec rofi -terminal ${term} -show ssh";
            "${mod}+s" = "layout tabbed";
            "${mod}+j" = "layout toggle split";
            "${mod}+f" = "fullscreen";
            "${mod}+Shift+space" = "floating toggle";
            "${mod}+${left}" = "focus left";
            "${mod}+${right}" = "focus right";
            "${mod}+${up}" = "focus up";
            "${mod}+${down}" = "focus down";
            "${mod}+Shift+${left}" = "move left";
            "${mod}+Shift+${right}" = "move right";
            "${mod}+Shift+${up}" = "move up";
            "${mod}+Shift+${down}" = "move down";
            "${mod}+Ctrl+${left}" = "move workspace output left";
            "${mod}+Ctrl+${right}" = "move workspace output right";
            "${mod}+Ctrl+${up}" = "move workspace output up";
            "${mod}+Ctrl+${down}" = "move workspace output down";
            "${mod}+1" = "workspace 1";
            "${mod}+2" = "workspace 2";
            "${mod}+3" = "workspace 3";
            "${mod}+4" = "workspace 4";
            "${mod}+5" = "workspace 5";
            "${mod}+6" = "workspace 6";
            "${mod}+7" = "workspace 7";
            "${mod}+8" = "workspace 8";
            "${mod}+9" = "workspace 9";
            "${mod}+0" = "workspace 10";
            "${mod}+Shift+1" = "move container to workspace 1";
            "${mod}+Shift+2" = "move container to workspace 2";
            "${mod}+Shift+3" = "move container to workspace 3";
            "${mod}+Shift+4" = "move container to workspace 4";
            "${mod}+Shift+5" = "move container to workspace 5";
            "${mod}+Shift+6" = "move container to workspace 6";
            "${mod}+Shift+7" = "move container to workspace 7";
            "${mod}+Shift+8" = "move container to workspace 8";
            "${mod}+Shift+9" = "move container to workspace 9";
            "${mod}+Shift+0" = "move container to workspace 10";
            "XF86MonBrightnessUp" = "exec light -T 1.4 && lightctl";
            "XF86MonBrightnessDown" = "exec light -T 0.72 && lightctl";
            "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer -t";
            "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
            "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -ud 2 && volumectl";
            "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -ui 2 && volumectl";
            "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
            "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
            "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
            "${mod}+l" = "exec ${pkgs.swaylock}/bin/swaylock # --screenshots --clock #--effect-blur 7x5 --effect-vignette 0.5:0.5 --effect-pixelate 2 --grace 5 --fade-in 0.5";
          };
        assigns = {
          "2" = [{ app_id = "firefox"; }];
          "3" = [{ class = "discord"; }];
          "4" = [{ class = "Spotify"; }];
        };
        startup = [
          #{ command = "avizo-service"; }
          { command = "${pkgs.mako}/bin/mako"; }
          { command = "${pkgs.ydotool}/bin/ydotoold"; }
          { command = "${pkgs.flameshot}/bin/flameshot"; }
          #{ command = "systemctl --user restart kanshi"; always = true; }
          #{ command = "systemctl --user restart waybar"; always = true; }
          # TODO investigate swayidle
          #{
          #  command = ''
          #    ${pkgs.swayidle}/bin/swayidle -w \
          #      timeout 120 '${pkgs.coreutils}/bin/echo `xbacklight -get` > /tmp/bn && xbacklight -set 10 -fps 20' \
          #        resume 'xbacklight -set `${pkgs.coreutils}/bin/cat /tmp/bn` -fps 20' \
          #      timeout 240 'swaylock -i ${lock_bg} -f -c 000000 && ${pkgs.sway-unwrapped}/bin/swaymsg  "output * dpms off"' \
          #        resume '${pkgs.sway-unwrapped}/bin/swaymsg "output * dpms on"' \
          #      before-sleep 'swaylock -i ${lock_bg} -f -c 000000'
          #  '';
          #}
        ] ++ (lib.optional (inputs.config.phil.wms.bars.waybar.enable)
          { command = "\"${pkgs.procps}/bin/pkill --signal 9 waybar; ${pkgs.waybar}/bin/waybar\""; always = true; }
        );

        window.commands = [
          {
            command = "inhibit_idle fullscreen";
            criteria = { app_id = "firefox"; };
          }
          {
            command = "opacity ${std_opacity}";
            criteria = { app_id = ".*"; };
          }
          {
            command = "floating enable";
            criteria = { title = "R Graphics.*"; };
          }
          {
            command = "opacity 1";
            criteria = { app_id = "firefox"; };
          }
          {
            command = "opacity 1";
            criteria = { app_id = "org.pwmt.zathura"; };
          }
          {
            command = "floating enable";
            criteria = { title = "vis"; };
          }
          {
            command = "floating enable, move to scratchpad";
            criteria = { title = ".+[Ss]haring (Indicator|your screen)"; };
          }
          {
            command = "floating enable";
            criteria = { app_id = "avizo-service"; };
          }
        ];
        output = { "*" = { bg = "${cfg.background_image} fill"; }; };
      };
    };

    programs = {
      mako = {
        enable = true;
        maxVisible = 5;
        defaultTimeout = 5000;
        font = "iosevka";
        backgroundColor = "#FFFFFF";
        textColor = "#000000";
        borderColor = "#000000";
        borderSize = 2;
        borderRadius = 4;
      };
      rofi = {
        enable = true;
        #package = pkgs.rofi-wayland;
      };
      alacritty = {
        enable = true;
        settings = {
          font.normal.family = "Iosevka Nerd Font";
          font.size = 12.0;
        };
      };
    };

    # for the work laptop
    services.kanshi = {
      enable = true;
      profiles = {
        "dockstation" = {
          exec = "notify-send 'Kanshi switched to dockstation profile'";
          outputs = [
            {
              criteria = "eDP-1";
              status = "disable";
            }
            {
              criteria = "Dell Inc. DELL U2415 XKV0P05J16ZS";
              mode = "1920x1200";
              position = "0,720";
            }
            {
              criteria = "Dell Inc. DELL U2415 XKV0P05J16YS";
              mode = "1920x1200";
              transform = "270";
              position = "1920,0";
            }
          ];
        };
        "default" = {
          exec = "notify-send 'Kanshi switched to default profile'";
          outputs = [
            {
              criteria = "eDP-1";
              status = "enable";
              mode = "1920x1080";
              position = "0,0";
            }
          ];
        };
        "at-home-1" = {
          exec = "notfiy-send 'Welcome home!'";
          outputs = [
            {
              criteria = "eDP-1";
              mode = "1920x1080";
              position = "0,0";
            }
            {
              criteria = "Philips Consumer Electronics Company PHL 245E1 0x000072DC";
              mode = "2560x1440@74.968Hz";
              position = "1920,0";
            }
          ];
        };
      };
    };

    xdg.configFile."foot/foot.ini".text = ''
      font=Iosevka Nerd Font:size=13
      bold-text-in-bright=yes
      dpi-aware=no

      [url]
      launch=firefox ''${url}
      osc8-underline=always
    '';

    home.packages = with pkgs; [
      swaylock

      flameshot
      #grim
      #slurp
      #sway-contrib.grimshot

      swayidle
      wl-clipboard
      imv
      feh
      wev
      wf-recorder
      xorg.xauth
      ydotool
      libnotify
      libappindicator
      glibcLocales
    ];
  };
}
