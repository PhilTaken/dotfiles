{
  pkgs,
  config,
  lib,
  nixosConfig,
  ...
}: let
  cfg = config.phil.wms.hyprland;
  inherit (lib) mkOption mkIf types mkEnableOption;
in {
  imports = [
    #inputs.hyprland.homeManagerModules.default
  ];

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
      default = nixosConfig.stylix.image;
    };

    default_font = mkOption {
      description = "default font";
      type = types.str;
      default = "Iosevka Comfy";
    };

    terminal = mkOption {
      description = "terminal to use";
      type = types.enum ["wezterm" "alacritty" "foot"];
      default = "alacritty";
    };
  };

  config = mkIf cfg.enable {
    phil.wms = {
      tools = {
        udiskie.enable = true;
        rofi = {
          enable = true;
          package = pkgs.rofi-wayland;
        };
      };
      serviceCommands = {
        wallpaper = "${pkgs.swaybg}/bin/swaybg -i ${cfg.background_image}";
      };
    };

    services.kanshi.systemdTarget = "hyprland-session.target";

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = 1;
      QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
      WLR_NO_HARDWARE_CURSORS = 1;
      CLUTTER_BACKEND = "wayland";
      XDG_SESSION_TYPE = "wayland";
      WLR_BACKEND = "vulkan";
      QT_QPA_PLATFORM = "wayland";
      GDK_BACKEND = "wayland";
      #LIBVA_DRIVER_NAME = "nvidia";
      #GBM_BACKEND = "nvidia-drm";
      #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };

    wayland.windowManager.hyprland = let
      inherit (cfg) terminal;

      #screenshot = "${pkgs.flameshot}/bin/flameshot gui";
      screenshot = "${pkgs.grim}/bin/grim -t jpeg -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy -t image/jpeg";

      lock = "swaylock -c 000000";
      menu = "rofi -show drun";

      left = "y";
      down = "n";
      up = "e";
      right = "o";
    in {
      enable = true;
      # TODO rewrite in nix with https://nix-community.github.io/home-manager/options.html#opt-wayland.windowManager.hyprland.settings
      extraConfig = ''
        monitor = DP-1,2560x1440@75,0x1080,1
        monitor = DVI-D-1,1920x1080@60,0x0,1
        #workspace = DP-1,1

        device:AT Translated Set 2 keyboard {
          kb_layout = us(workman-intl),us(intl),
          kb_options = caps:escape,grp:shifts_toggle,
        }

        input {
            kb_layout = us,
            kb_options = caps:escape,
        }

        general {
            # for mouse cursor
            sensitivity = 1.0

            gaps_in = 5
            gaps_out = 5
            border_size = 0
            # col.active_border = 0x66ee1111
            col.active_border = 0x66883333
            col.inactive_border = 0xffffffff

            apply_sens_to_raw = 0 # whether to apply the sensitivity to raw input (e.g. used by games where you aim using your mouse)
        }

        decoration {
            rounding = 10

            # Your blur "amount" is blur_size * blur_passes, but high blur_size (over around 5-ish) will produce artifacts.
            # if you want heavy blur, you need to up the blur_passes.
            # the more passes, the more you can up the blur_size without noticing artifacts.

            blur = yes
            blur_size = 2 # minimum 1
            blur_passes = 5 # minimum 1, more passes = more resource intensive.
            blur_new_optimizations = on

            dim_inactive = true
            dim_strength = 0.1

            drop_shadow = yes
            shadow_range = 10
            shadow_render_power = 5
            col.shadow = rgba(1a1a1aee)
        }

        animations {
            enabled = yes

            bezier = myBezier, 0.05, 0.9, 0.1, 1.05
            bezier = windowOpen, 0.01, 0.97, 0.5, 1.0
            bezier = workspaceSwitch, 0.11, 0.76, 0.04, 1

            animation = windows, 1, 4, windowOpen
            animation = windowsOut, 1, 7, default, popin 70%
            animation = border, 1, 10, default
            animation = fade, 1, 7, default
            animation = workspaces, 1, 5, workspaceSwitch
        }

        dwindle {
            pseudotile = 0 # enable pseudotiling on dwindle
            preserve_split = yes
        }

        master {
            # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
            new_is_master = true
            no_gaps_when_only = true
        }

        # make pinentry fancy
        windowrule = float,Pinentry
        windowrule = noborder,Pinentry
        windowrule = dimaround,Pinentry

        windowrule = float,Media viewer
        windowrule = float,pavucontrol
        windowrule = float,title:Bluetooth Devices
        windowrule = float,title:Picture-in-Picture
        windowrule = float,title:Firefox — Sharing Indicator
        windowrule = float,float

        # mouse binds
        bindm = SUPER,mouse:272,movewindow
        bindm = SUPER,mouse:273,resizewindow

        # Scroll through existing workspaces with mainMod + scroll
        bind = SUPER, mouse_down, workspace, e-1
        bind = SUPER, mouse_up, workspace, e+1

        # keyboard binds
        bind = SUPER,P,pseudo,
        bind = SUPER,D,killactive,
        bind = SUPER,C,exit,
        bind = SUPERSHIFT,space,togglefloating,

        bind = SUPER,space,exec,${menu}
        bind = SUPER,return,exec,${pkgs.${terminal}}/bin/${terminal}
        bind = SUPER,l,exec,${lock}
        bind = SUPER,q,exec,${screenshot}

        bind = SUPER,${left},movefocus,l
        bind = SUPER,${down},movefocus,d
        bind = SUPER,${up},movefocus,u
        bind = SUPER,${right},movefocus,r

        bind = SUPERCONTROL,${left},movecurrentworkspacetomonitor,l
        bind = SUPERCONTROL,${down},movecurrentworkspacetomonitor,d
        bind = SUPERCONTROL,${up},movecurrentworkspacetomonitor,u
        bind = SUPERCONTROL,${right},movecurrentworkspacetomonitor,r

        bind = SUPER,1,workspace,1
        bind = SUPER,2,workspace,2
        bind = SUPER,3,workspace,3
        bind = SUPER,4,workspace,4
        bind = SUPER,5,workspace,5
        bind = SUPER,6,workspace,6
        bind = SUPER,7,workspace,7
        bind = SUPER,8,workspace,8
        bind = SUPER,9,workspace,9
        bind = SUPER,0,workspace,10

        bind = SUPERSHIFT,1,movetoworkspace,1
        bind = SUPERSHIFT,2,movetoworkspace,2
        bind = SUPERSHIFT,3,movetoworkspace,3
        bind = SUPERSHIFT,4,movetoworkspace,4
        bind = SUPERSHIFT,5,movetoworkspace,5
        bind = SUPERSHIFT,6,movetoworkspace,6
        bind = SUPERSHIFT,7,movetoworkspace,7
        bind = SUPERSHIFT,8,movetoworkspace,8
        bind = SUPERSHIFT,9,movetoworkspace,9
        bind = SUPERSHIFT,0,movetoworkspace,10

        bind = ,XF86MonBrightnessUp,exec,light -T 1.4
        bind = ,XF86MonBrightnessDown,exec,light -T 0.72
        bind = ,XF86AudioMute,exec,${pkgs.pamixer}/bin/pamixer -t
        bind = ,XF86AudioMicMute,exec,pactl set-source-mute @DEFAULT_SOURCE@ toggle
        bind = ,XF86AudioLowerVolume,exec,${pkgs.pamixer}/bin/pamixer -ud 2
        bind = ,XF86AudioRaiseVolume,exec,${pkgs.pamixer}/bin/pamixer -ui 2
        bind = ,XF86AudioPrev,exec,${pkgs.playerctl}/bin/playerctl previous
        bind = ,XF86AudioNext,exec,${pkgs.playerctl}/bin/playerctl next
        bind = ,XF86AudioPlay,exec,${pkgs.playerctl}/bin/playerctl play-pause

        exec-once = systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
      '';
    };

    # TODO: move someplace else
    services = {
      mako = {
        enable = true;
        maxVisible = 5;
        defaultTimeout = 5000;
        borderSize = 2;
        borderRadius = 4;
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
