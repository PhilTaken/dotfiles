{
  pkgs,
  username,
  background_image,
  ...
}:
let
  lock_bg = ../.. + "/${username}/wallpaper/lock.jpg";
  sway_bg = ../.. + "/${username}/wallpaper/${background_image}";
in rec {
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      assigns = {
        "1: Terminal" = [{ class = "alacritty"; }];
        "2: Web" = [{ class = "^Firefox$"; }];
        "4: Spotify" = [{ class = "Spotify"; }];
      };
      floating = {
        border = 0;
        criteria = [ { title = "Steam - Update News"; } { class = "Pavucontrol"; } ];
      };
      gaps = {
        inner = 12;
        outer = 0;
        smartBorders = "on";
      };
      keybindings = let
        modifier = xsession.windowManager.i3.config.modifier;
        terminal = "${programs.alacritty.package}/bin/alacritty";
      in {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+d" = "kill";
        "${modifier}+Space" = "${programs.rofi.package}/bin/rofi -show run";
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
        font.normal.family = "iosevka";
        font.size = 12.0;
      };
    };
  };

  services.picom = {
    enable = true;
    activeOpacity = "0.8";
    blur = true;
    blurExclude = [ "class_g = 'slop'" "class_i = 'polybar'" ];
    fade = true;
    inactiveDim = "0.1";
    inactiveOpacity = "0.6";
    shadow = true;
  };

  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3GapsSupport = true;
      githubSupport = true;
    };
    config = {
      "bar/top" = {
        monitor = "\${env:MONITOR:eDP1}";
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
    enable = true;
    package = pkgs.pulseeffects-legacy;
  };

  home.packages = with pkgs; [
    feh
    xorg.xauth
    xdotool
    libnotify
    libappindicator
    glibcLocales
  ];
}
