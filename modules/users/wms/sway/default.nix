{
  pkgs,
  config,
  lib,
  ...
} @ inputs: let
  cfg = config.phil.wms.sway;
  inherit
    (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in {
  options.phil.wms.sway = {
    enable = mkEnableOption "sway";

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

    default_font = mkOption {
      description = "default font";
      type = types.str;
      default = "Iosevka Comfy";
    };

    # TODO: enum? pkg?
    terminal = mkOption {
      description = "default terminal";
      type = types.str;
      default = "wezterm";
    };
  };

  config = mkIf cfg.enable rec {
    phil.wms.tools.udiskie.enable = true;
    phil.wms.tools.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
    };

    home.sessionVariables = {
      #XDG_CURRENT_DESKTOP = "sway";
      MOZ_ENABLE_WAYLAND = 1;
    };

    home.shellAliases = {
      sockfix = "export SWAYSOCK=/run/user/$(id -u)/sway-ipc.$(id -u).$(pgrep -x sway).sock";
    };

    wayland.windowManager.sway = let
      std_opacity = "0.96";
      lock = "swaylock -c 000000";
      menu = "rofi -show drun";
    in {
      enable = true;
      wrapperFeatures.gtk = true;

      config = {
        up = "e";
        down = "n";
        left = "y";
        right = "o";
        modifier = "Mod4";
        terminal = "${pkgs.${cfg.terminal}}/bin/${cfg.terminal}";
        floating.border = 0;
        focus.followMouse = "always";
        bindkeysToCode = false;
        bars = [];
        gaps = {
          inner = 12;
          outer = 0;
          smartBorders = "on";
        };

        input = {
          # intuos pen
          "1386:827:Wacom_Intuos_S_2_Pen" = {
            map_from_region = "0.75x0 1x0.3";
          };

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
          # wireless lopro corne
          "7504:24926:ZMK_Project_Corne_Keyboard" = {
            xkb_layout = "us(intl)";
          };
          # all other keyboard
          "*" = {
            xkb_layout = "us(workman-intl)";
            xkb_options = "caps:escape";
          };
        };

        keybindings = let
          inherit menu;
          inherit
            (wayland.windowManager.sway.config)
            terminal
            modifier
            up
            down
            left
            right
            ;
        in {
          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+u" = "exit";
          "${modifier}+Return" = "exec ${terminal}";
          "${modifier}+q" = "exec ${pkgs.flameshot}/bin/flameshot gui";
          "${modifier}+d" = "kill";
          "${modifier}+Space" = "exec ${menu}";
          "${modifier}+p" = "exec gopass-rofi";
          "${modifier}+u" = "exec rofi -terminal ${terminal} -show ssh";
          "${modifier}+s" = "layout tabbed";
          "${modifier}+j" = "layout toggle split";
          "${modifier}+f" = "fullscreen";
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+${left}" = "focus left";
          "${modifier}+${right}" = "focus right";
          "${modifier}+${up}" = "focus up";
          "${modifier}+${down}" = "focus down";
          "${modifier}+Shift+${left}" = "move left";
          "${modifier}+Shift+${right}" = "move right";
          "${modifier}+Shift+${up}" = "move up";
          "${modifier}+Shift+${down}" = "move down";
          "${modifier}+Ctrl+${left}" = "move workspace output left";
          "${modifier}+Ctrl+${right}" = "move workspace output right";
          "${modifier}+Ctrl+${up}" = "move workspace output up";
          "${modifier}+Ctrl+${down}" = "move workspace output down";
          "${modifier}+1" = "workspace 1";
          "${modifier}+2" = "workspace 2";
          "${modifier}+3" = "workspace 3";
          "${modifier}+4" = "workspace 4";
          "${modifier}+5" = "workspace 5";
          "${modifier}+6" = "workspace 6";
          "${modifier}+7" = "workspace 7";
          "${modifier}+8" = "workspace 8";
          "${modifier}+9" = "workspace 9";
          "${modifier}+0" = "workspace 10";
          "${modifier}+Shift+1" = "move container to workspace 1";
          "${modifier}+Shift+2" = "move container to workspace 2";
          "${modifier}+Shift+3" = "move container to workspace 3";
          "${modifier}+Shift+4" = "move container to workspace 4";
          "${modifier}+Shift+5" = "move container to workspace 5";
          "${modifier}+Shift+6" = "move container to workspace 6";
          "${modifier}+Shift+7" = "move container to workspace 7";
          "${modifier}+Shift+8" = "move container to workspace 8";
          "${modifier}+Shift+9" = "move container to workspace 9";
          "${modifier}+Shift+0" = "move container to workspace 10";

          "XF86MonBrightnessUp" = "exec light -T 1.4 && lightctl";
          "XF86MonBrightnessDown" = "exec light -T 0.72 && lightctl";
          "XF86AudioMute" = "exec ${pkgs.pamixer}/bin/pamixer -t";
          "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          "XF86AudioLowerVolume" = "exec ${pkgs.pamixer}/bin/pamixer -ud 2 && volumectl";
          "XF86AudioRaiseVolume" = "exec ${pkgs.pamixer}/bin/pamixer -ui 2 && volumectl";
          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
          "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "${modifier}+l" = "exec ${lock}";
        };
        assigns = {
          "2" = [{app_id = "firefox";}];
          "3" = [{class = "discord";}];
          "4" = [{class = "Spotify";}];
        };
        startup =
          [
            #{ command = "avizo-service"; }
            {command = "${pkgs.mako}/bin/mako";}
            {command = "${pkgs.ydotool}/bin/ydotoold";}
            {command = "${pkgs.flameshot}/bin/flameshot";}
            #{ command = "systemctl --user restart kanshi"; always = true; }
            #{ command = "systemctl --user restart waybar"; always = true; }
            # TODO investigate swayidle
            #{
            #  command = ''
            #    ${pkgs.swayidle}/bin/swayidle -w \
            #      timeout 120 '${pkgs.uutils-coreutils}/bin/echo `xbacklight -get` > /tmp/bn && xbacklight -set 10 -fps 20' \
            #        resume 'xbacklight -set `${pkgs.uutils-coreutils}/bin/cat /tmp/bn` -fps 20' \
            #      timeout 240 'swaylock -i ${lock_bg} -f -c 000000 && ${pkgs.sway-unwrapped}/bin/swaymsg  "output * dpms off"' \
            #        resume '${pkgs.sway-unwrapped}/bin/swaymsg "output * dpms on"' \
            #      before-sleep 'swaylock -i ${lock_bg} -f -c 000000'
            #  '';
            #}
          ]
          ++ (lib.optional (inputs.config.phil.wms.bars.barcommand != "") {
            command = inputs.config.phil.wms.bars.barcommand;
            always = false;
          });

        window.commands = [
          {
            command = "inhibit_idle fullscreen";
            criteria = {
              app_id = "firefox";
            };
          }
          {
            command = "opacity ${std_opacity}";
            criteria = {
              app_id = ".*";
            };
          }
          {
            command = "floating enable";
            criteria = {
              title = "R Graphics.*";
            };
          }
          {
            command = "opacity 1";
            criteria = {
              app_id = "librewolf|firefox";
            };
          }
          {
            command = "opacity 1";
            criteria = {
              app_id = "org.pwmt.zathura";
            };
          }
          {
            command = "floating enable";
            criteria = {
              title = "vis";
            };
          }
          {
            command = "floating enable, move to scratchpad";
            criteria = {
              title = ".+[Ss]haring (Indicator|your screen)";
            };
          }
          {
            command = "floating enable";
            criteria = {
              app_id = "avizo-service";
            };
          }
        ];
        output = {
          "*" = {
            bg = "${cfg.background_image} fill";
          };
        };
      };
    };

    services = {
      mako = {
        enable = true;
        settings = {
          max-visible = 5;
          default-timeout = 5000;
          border-size = 2;
          border-radius = 4;
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

    home.packages = with pkgs; [
      swaylock
      flameshot

      #grim
      #slurp
      #sway-contrib.grimshot

      swayidle
      wl-clipboard
      feh
      wev
      #wf-recorder
      ydotool

      libnotify
      libappindicator
      glibcLocales

      xorg.xauth
    ];
  };
}
