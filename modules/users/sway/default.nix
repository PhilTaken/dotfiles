{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.sway;
  #lock_bg = ../../users + "/${username}/wallpaper/lock.jpg";
in
rec {
  options.phil.sway = {
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
  };

  config = mkIf (cfg.enable) {
    wayland.windowManager.sway =
      let
        std_opacity = "0.96";
        lock = "swaylock -c 000000";
        screen_recorder = ./record_screen.sh;
      in
      {
        enable = true;
        config = {
          up = "e";
          down = "n";
          left = "y";
          right = "o";
          modifier = "Mod4";
          terminal = "${pkgs.foot}/bin/foot";
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
              left = swayconf.left;
              right = swayconf.right;
              up = swayconf.up;
              down = swayconf.down;
              term = swayconf.terminal;
              mod = swayconf.modifier;
              menu = swayconf.menu;
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
            } // (mkIf (cfg.lock_bg != null) {
              "${mod}+l" = "exec ${pkgs.swaylock}/bin/swaylock -i ${lock_bg} &";
            });
          assigns = {
            "2" = [{ app_id = "firefox"; }];
            "3" = [{ class = "discord"; }];
            "4" = [{ class = "Spotify"; }];
          };
          startup = [
            #{ command = "avizo-service"; }
            { command = "${pkgs.mako}/bin/mako"; }
            { command = "${pkgs.ydotool}/bin/ydotoold"; }
            { command = "\"${pkgs.procps}/bin/pkill --signal 9 waybar; ${pkgs.waybar}/bin/waybar\""; always = true; }
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
          ];
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
          output = { "*" = { bg = "${background_image} fill"; }; };
        };
      };

    programs.waybar =
      let
        css_file = ./style.css;
      in
      {
        enable = true;
        settings = [
          {
            layer = "top";
            position = "top";
            height = 15;
            modules-left = [ "idle_inhibitor" "sway/workspaces" "sway/mode" ];
            #modules-center = [ "custom/weather" ];
            modules-right = [ "pulseaudio" "battery" "memory" "network" "custom/vpn" "clock" "tray" ];
            modules = {
              "sway/workspaces" = {
                icon-size = 20;
                disable-scroll = true;
                all-outputs = false;
                format = "{name}";
              };
              "sway/mode".format = "<span style=\"italic\">{}</span>";
              "idle_inhibitor" = {
                format = "{icon}";
                format-icons.activated = "";
                format-icons.deactivated = "";
              };
              "tray".spacing = 10;
              "clock" = {
                tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
                format-alt = "{:%Y-%m-%d}";
              };
              "memory".format = "{}% ";
              "battery" = {
                states.warning = 30;
                states.critical = 15;
                format = "{capacity}% {icon}";
                format-icons = [ "" "" "" "" "" ];
              };
              "network" = {
                format-wifi = "{essid} ({signalStrength}%) ";
                format-ethernet = "{ifname} ";
                format-disconnected = "Disconnected ⚠";
                on-click = "cmst";
                tooltip-format = "{ipaddr}/{cidr}, {bandwidthUpBits} up, {bandwidthDownBits} down";
              };
              "pulseaudio" = {
                scroll-step = 5;
                format = "{volume}% {icon}";
                format-muted = "{icon}";
                format-icons = {
                  headphones = "";
                  default = [ "" "" ];
                };
                on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
                on-click-right = "pavucontrol";
              };
              "custom/vpn" = {
                interval = 1;
                return-type = "json";
                exec = pkgs.writeShellScript "vpn" ''
                  wg >/dev/null 2>&1
                  connected=$?

                  if [ $connected -eq 1 ]; then
                  icon=""
                  class="connected"
                  else
                  icon=""
                  class="disconnected"
                  fi

                  echo -e "{\"text\":\""$icon"\", \"tooltip\":\"Wireguard VPN ("$class")\", \"class\":\""$class"\"}"
                '';
                escape = true;
              };
              #"custom/weather" = {
              #interval = 900;
              #exec = "${weather_exec}";
              #};
            };
          }
        ];
        style = builtins.readFile css_file;
        #systemd.enable = true;
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
      #alacritty = {
      #enable = true;
      #settings = {
      #font.normal.family = "iosevka";
      #font.size = 12.0;
      #};
      #};
    };

    services.pulseeffects = {
      enable = true;
      package = pkgs.pulseeffects-pw;
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
