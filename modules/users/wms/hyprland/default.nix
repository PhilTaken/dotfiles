{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.wms.hyprland;
in
rec {
  options.phil.wms.hyprland = {
    enable = mkEnableOption "hyprland";

    lock_bg = mkOption {
      description = "Locking background";
      type = types.nullOr types.path;
      default = null;
    };

    background_image = mkOption {
      description = "Background image";
      type = types.path;
      default = ../../../../images/cat-sound.png;
    };

    default_font = mkOption {
      description = "default font";
      type = types.str;
      default = "Iosevka Comfy";
    };
  };

  config = mkIf cfg.enable rec {
    phil.wms.tools.udiskie.enable = true;

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
    };

    wayland.windowManager.hyprland =
      let
        #terminal = "${pkgs.foot}/bin/foot";
        terminal = "${pkgs.wezterm}/bin/wezterm";
        #terminal = "${pkgs.alacritty}/bin/alacritty";

        #screenshot = "${pkgs.flameshot}/bin/flameshot gui";
        screenshot = "${pkgs.grim}/bin/grim -t jpeg -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/jpeg";

        lock = "swaylock -c 000000";
        menu = "${pkgs.rofi-wayland}/bin/rofi -show run";

        inherit (inputs.config.phil.wms.bars) barcommand;
        left = "y";
        down = "n";
        up = "e";
        right = "o";
      in
      {
        enable = true;
        extraConfig = ''
          # This is an example Hyprland config file.
          # Syntax is the same as in Hypr, but settings might differ.
          #
          # Refer to the wiki for more information.

          monitor=DP-1,2560x1440@75,0x1080,1
          monitor=DVI-D-1,1920x1080@60,0x0,1
          #workspace=DP-1,1

          device:AT Translated Set 2 keyboard {
            kb_layout=us(workman-intl),us(intl),
            kb_options=caps:escape,grp:shifts_toggle,
          }

          input {
              kb_layout=us,
              kb_options=caps:escape,
          }

          general {
              sensitivity=1.0 # for mouse cursor
              main_mod=SUPER

              gaps_in=5
              gaps_out=5
              border_size=1
              # col.active_border=0x66ee1111
              col.active_border=0x66883333
              col.inactive_border=0x66333333

              apply_sens_to_raw=0 # whether to apply the sensitivity to raw input (e.g. used by games where you aim using your mouse)
              damage_tracking=full # leave it on full unless you hate your GPU and want to make it suffer
          }

          decoration {
              rounding=5
              blur=1
              blur_size=3 # minimum 1
              blur_passes=1 # minimum 1, more passes = more resource intensive.
              # Your blur "amount" is blur_size * blur_passes, but high blur_size (over around 5-ish) will produce artifacts.
              # if you want heavy blur, you need to up the blur_passes.
              # the more passes, the more you can up the blur_size without noticing artifacts.
          }

          animations {
              enabled=1
              animation=windows,1,7,default
              animation=border,1,10,default
              animation=fade,1,10,default
              animation=workspaces,1,6,default
          }

          dwindle {
              pseudotile=0 # enable pseudotiling on dwindle
          }


          windowrule=float,Pinentry
          windowrule=float,Media viewer
          windowrule=float,title:Picture-in-Picture
          windowrule=float,title:Firefox — Sharing Indicator

          # example window rules
          # for windows named/classed as abc and xyz
          #windowrule=move 69 420,abc
          #windowrule=size 420 69,abc
          #windowrule=tile,xyz
          #windowrule=float,abc
          #windowrule=pseudo,abc
          #windowrule=monitor 0,xyz

          # mouse binds
          bindm=SUPER,mouse:272,movewindow
          bindm=SUPER,mouse:273,resizewindow

          # keyboard binds
          bind=SUPER,P,pseudo,
          bind=SUPER,D,killactive,
          bind=SUPER,C,exit,
          bind=SUPERSHIFT,space,togglefloating,

          bind=SUPER,space,exec,${menu}
          bind=SUPER,return,exec,${terminal}
          bind=SUPER,l,exec,${lock}
          bind=SUPER,q,exec,${screenshot}

          bind=SUPER,${left},movefocus,l
          bind=SUPER,${down},movefocus,d
          bind=SUPER,${up},movefocus,u
          bind=SUPER,${right},movefocus,r

          bind=SUPERCONTROL,${left},movecurrentworkspacetomonitor,l
          bind=SUPERCONTROL,${down},movecurrentworkspacetomonitor,d
          bind=SUPERCONTROL,${up},movecurrentworkspacetomonitor,u
          bind=SUPERCONTROL,${right},movecurrentworkspacetomonitor,r

          bind=SUPER,1,workspace,1
          bind=SUPER,2,workspace,2
          bind=SUPER,3,workspace,3
          bind=SUPER,4,workspace,4
          bind=SUPER,5,workspace,5
          bind=SUPER,6,workspace,6
          bind=SUPER,7,workspace,7
          bind=SUPER,8,workspace,8
          bind=SUPER,9,workspace,9
          bind=SUPER,0,workspace,10

          bind=SUPERSHIFT,1,movetoworkspace,1
          bind=SUPERSHIFT,2,movetoworkspace,2
          bind=SUPERSHIFT,3,movetoworkspace,3
          bind=SUPERSHIFT,4,movetoworkspace,4
          bind=SUPERSHIFT,5,movetoworkspace,5
          bind=SUPERSHIFT,6,movetoworkspace,6
          bind=SUPERSHIFT,7,movetoworkspace,7
          bind=SUPERSHIFT,8,movetoworkspace,8
          bind=SUPERSHIFT,9,movetoworkspace,9
          bind=SUPERSHIFT,0,movetoworkspace,10

          bind=,XF86MonBrightnessUp,exec,light -T 1.4
          bind=,XF86MonBrightnessDown,exec,light -T 0.72
          bind=,XF86AudioMute,exec,${pkgs.pamixer}/bin/pamixer -t
          bind=,XF86AudioMicMute,exec,pactl set-source-mute @DEFAULT_SOURCE@ toggle
          bind=,XF86AudioLowerVolume,exec,${pkgs.pamixer}/bin/pamixer -ud 2
          bind=,XF86AudioRaiseVolume,exec,${pkgs.pamixer}/bin/pamixer -ui 2
          bind=,XF86AudioPrev,exec,${pkgs.playerctl}/bin/playerctl previous
          bind=,XF86AudioNext,exec,${pkgs.playerctl}/bin/playerctl next
          bind=,XF86AudioPlay,exec,${pkgs.playerctl}/bin/playerctl play-pause

          exec-once=systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
          exec-once=${pkgs.swaybg}/bin/swaybg -i ${cfg.background_image}
          exec-once=${barcommand}
        '';
      };


    # TODO: move someplace else
    programs = {
      mako = {
        enable = true;
        maxVisible = 5;
        defaultTimeout = 5000;
        font = cfg.default_font;
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
    };

    home.packages = with pkgs; [
      wofi

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
