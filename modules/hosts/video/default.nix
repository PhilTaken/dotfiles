{
  pkgs,
  npins,
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    types
    mkForce
    ;
  cfg = config.phil.video;

  session_map = {
    "xfce" = "xfce";
    "kde" = "plasma";
    "gnome" = "gnome";
    "cosmic" = "cosmic";
  };

  manager_enum = types.enum (builtins.attrNames session_map);
  enabled = lib.flip builtins.elem cfg.managers;
in
{
  options.phil.video = {
    enable = mkOption {
      description = "enable video module";
      type = types.bool;
      default = true;
    };

    managers = mkOption {
      description = "which window/desktop manager to enable";
      type = types.listOf manager_enum;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    hardware.graphics.enable = true;
    console.useXkbConfig = true;

    fonts.packages = [
      pkgs.font-awesome
      pkgs.iosevka-comfy.comfy
      pkgs.nerd-fonts.sauce-code-pro
      pkgs.nerd-fonts.iosevka
    ];

    # https://github.com/nix-community/home-manager/issues/2017
    # https://github.com/NixOS/nixpkgs/issues/158025
    programs.sway.enable = false;
    programs.hyprland.enable = true;
    # https://wiki.hyprland.org/Nix/#modules-mixnmatch
    #programs.hyprland.package = null;

    boot.plymouth.enable = true;

    services.displayManager.defaultSession = mkIf (
      cfg.managers != [ ]
    ) session_map.${builtins.head cfg.managers};

    services.displayManager.cosmic-greeter.enable = true;
    services.displayManager.gdm = {
      enable = false;
      wayland = true;
      autoLogin.delay = 10;
    };

    services.libinput.enable = true;

    services.xserver = {
      enable = true;
      xkb.layout = "us";
      xkb.variant = "intl,workman-intl";
      xkb.options = "caps:escape,grp:shifts_toggle";

      desktopManager = {
        plasma6.enable = enabled "kde";
        xfce.enable = enabled "xfce";
        #xterm.enable = true;
      };
    };
    services.desktopManager.cosmic.enable = enabled "cosmic";
    services.desktopManager.gnome.enable = enabled "gnome";

    # ----------------------
    # gnome
    services.gnome.gnome-browser-connector.enable = enabled "gnome";
    services.gnome.core-apps.enable = enabled "gnome";
    services.gnome.core-os-services.enable = enabled "gnome";
    services.gnome.gnome-keyring.enable = mkForce false;

    services.udev.packages = [ ] ++ (lib.optional (enabled "gnome") pkgs.gnome-settings-daemon);
    services.dbus.packages = [ ] ++ (lib.optional (enabled "gnome") pkgs.dconf);
    programs.dconf.enable = true;

    # enable kdeconnect + open the required ports
    programs.kdeconnect.enable = true;
    networking.firewall =
      let
        kde_ports = lib.range 1714 1764;
      in
      {
        allowedTCPPorts = kde_ports ++ [ 8888 ];
        allowedUDPPorts = kde_ports ++ [ 8888 ];
      };

    # https://github.com/NixOS/nixpkgs/issues/163107#issuecomment-1100569484
    environment.systemPackages = [
      pkgs.slurp
      pkgs.adwaita-icon-theme
      pkgs.shared-mime-info
      pkgs.wl-clipboard
    ];

    environment.pathsToLink = [
      "/share/icons"
      "/share/mime"
    ];

    xdg = {
      portal = {
        xdgOpenUsePortal = true;
        enable = true;
        config.common = {
          default = [
            "gtk"
            "gnome"
          ];

          # gnome-keyring interfaces
          #"org.freedesktop.impl.portal.Secret" = "gnome-keyring";

          # GTK interfaces
          "org.freedesktop.impl.portal.FileChooser" = "gtk";
          "org.freedesktop.impl.portal.AppChooser" = "gtk";
          "org.freedesktop.impl.portal.Print" = "gtk";
          "org.freedesktop.impl.portal.Notification" = "gtk";
          # "org.freedesktop.impl.portal.Inhibit" = "gtk";
          "org.freedesktop.impl.portal.Access" = "gtk";
          "org.freedesktop.impl.portal.Account" = "gtk";
          "org.freedesktop.impl.portal.Email" = "gtk";
          "org.freedesktop.impl.portal.DynamicLauncher" = "gtk";
          "org.freedesktop.impl.portal.Lockdown" = "gtk";
          "org.freedesktop.impl.portal.Wallpaper" = "gtk";

          # Gnome interfaces
          # "org.freedesktop.impl.portal.Access" = "gnome";
          # "org.freedesktop.impl.portal.Account" = "gnome";
          # "org.freedesktop.impl.portal.AppChooser" = "gnome";
          "org.freedesktop.impl.portal.Background" = "gnome";
          "org.freedesktop.impl.portal.Clipboard" = "gnome";
          # "org.freedesktop.impl.portal.DynamicLauncher" = "gnome";
          # "org.freedesktop.impl.portal.FileChooser" = "gnome";
          "org.freedesktop.impl.portal.InputCapture" = "gnome";
          # "org.freedesktop.impl.portal.Lockdown" = "gnome";
          # "org.freedesktop.impl.portal.Notification" = "gnome";
          # "org.freedesktop.impl.portal.Print" = "gnome";
          "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
          # "org.freedesktop.impl.portal.ScreenCast" = "gnome";
          # "org.freedesktop.impl.portal.Screenshot" = "gnome";
          "org.freedesktop.impl.portal.Settings" = "gnome";
          # "org.freedesktop.impl.portal.Wallpaper" = "gnome";
        };
        wlr = {
          enable = false;
          settings = {
            screencast = {
              #max_fps = 30;
              chooser_type = "simple";
              chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
              #chooser_cmd = "${pkgs.hyprland-share-picker}/bin/hyprland-share-picker";
            };
          };
        };
        extraPortals = with pkgs; [
          #xdg-desktop-portal-hyprland
          #xdg-desktop-portal-wlr
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
        ];
      };
    };

    stylix = {
      enable = true;
      enableReleaseChecks = false;

      image = lib.mkDefault ../../../images/vortex.png;
      polarity = "dark";
      base16Scheme = lib.mkDefault "${npins.base16}/base16/mocha.yaml";

      fonts = {
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };

        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };

        monospace = {
          #package = pkgs.dejavu_fonts;
          #name = "DejaVu Sans Mono";
          package = pkgs.iosevka-comfy.comfy-duo;
          name = "Iosevka Comfy";
        };

        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
