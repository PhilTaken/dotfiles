{
  pkgs,
  npins,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkForce;
  cfg = config.phil.video;

  session_map = {
    "xfce" = "xfce";
    "kde" = "plasma";
    "gnome" = "gnome";
    #"cosmic" = "cosmic";
  };

  manager_enum = types.enum (builtins.attrNames session_map);
  enabled = lib.flip builtins.elem cfg.managers;
in {
  options.phil.video = {
    enable = mkOption {
      description = "enable video module";
      type = types.bool;
      default = true;
    };

    driver = mkOption {
      description = "video driver";
      type = types.nullOr (types.enum ["noveau" "nvidia" "amd" "qxl"]);
      default = null;
    };

    managers = mkOption {
      description = "which window/desktop manager to enable";
      type = types.listOf manager_enum;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config = mkIf (cfg.driver == "nvidia") {
      allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "nvidia-x11"
          "nvidia-settings"
        ];
    };

    hardware.graphics.enable = true;
    console.useXkbConfig = true;

    fonts.packages = [
      pkgs.font-awesome
      pkgs.iosevka-comfy.comfy
      (pkgs.nerdfonts.override {fonts = ["SourceCodePro" "Iosevka"];})
    ];

    # https://github.com/nix-community/home-manager/issues/2017
    # https://github.com/NixOS/nixpkgs/issues/158025
    programs.sway.enable = true;
    programs.hyprland.enable = true;
    # https://wiki.hyprland.org/Nix/#modules-mixnmatch
    #programs.hyprland.package = null;

    boot.plymouth.enable = true;

    services.displayManager.defaultSession = mkIf (cfg.managers != []) session_map.${builtins.head cfg.managers};

    #services.displayManager.cosmic-greeter.enable = true;
    services.xserver.displayManager.gdm = {
      enable = true;
      wayland = true;
      autoLogin.delay = 10;
    };

    services.libinput.enable = true;

    services.xserver = {
      enable = true;
      xkb.layout = "us";
      xkb.variant = "intl,workman-intl";
      xkb.options = "caps:escape,grp:shifts_toggle";

      videoDrivers =
        if (cfg.driver != null)
        then [cfg.driver]
        else [];

      screenSection = mkIf (cfg.driver == "nvidia") ''
        Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
        Option         "AllowIndirectGLXProtocol" "off"
        Option         "TripleBuffer" "on"
      '';

      desktopManager = {
        plasma5.enable = enabled "kde";
        xfce.enable = enabled "xfce";
        gnome.enable = enabled "gnome";
        #xterm.enable = true;
      };
    };
    #services.desktopManager.cosmic.enable = enabled "cosmic";

    # ----------------------
    # gnome
    services.gnome.gnome-browser-connector.enable = enabled "gnome";
    services.gnome.gnome-keyring.enable = mkForce false;
    services.udev.packages = [] ++ (lib.optional (enabled "gnome") pkgs.gnome-settings-daemon);
    services.dbus.packages = [] ++ (lib.optional (enabled "gnome") pkgs.dconf);
    programs.dconf.enable = true;

    # enable kdeconnect + open the required ports
    programs.kdeconnect.enable = true;
    networking.firewall = let
      kde_ports = lib.range 1714 1764;
    in {
      allowedTCPPorts = kde_ports ++ [8888];
      allowedUDPPorts = kde_ports ++ [8888];
    };

    # https://github.com/NixOS/nixpkgs/issues/163107#issuecomment-1100569484
    environment.systemPackages = with pkgs; [
      slurp
      pkgs.adwaita-icon-theme
      pkgs.shared-mime-info
    ];

    environment.pathsToLink = [
      "/share/icons"
      "/share/mime"
    ];

    # https://wiki.hyprland.org/Nvidia/#how-to-get-hyprland-to-possibly-work-on-nvidia
    environment.variables = mkIf (cfg.driver == "nvidia") {
      GBM_BACKEND = "nvidia-drm";
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";

      WLR_NO_HARDWARE_CURSORS = "1";
      #WLR_BACKEND = "vulkan";

      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      MOZ_ENABLE_WAYLAND = "1";
      #NIXOS_OZONE_WL = "1";
      #CLUTTER_BACKEND = "wayland";
      #XDG_SESSION_TYPE = "wayland";
      QT_QPA_PLATFORM = "wayland";
      #GDK_BACKEND = "wayland";
    };

    xdg = {
      portal = {
        enable = true;
        wlr = {
          enable = true;
          settings = {
            screencast = {
              #max_fps = 30;
              chooser_type = "simple";
              chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
              #chooser_cmd = "${pkgs.hyprland-share-picker}/bin/hyprland-share-picker";
            };
          };
        };
        #gtkUsePortal = true;
        extraPortals = with pkgs; [
          #xdg-desktop-portal-hyprland
          xdg-desktop-portal-wlr
          #xdg-desktop-portal-gtk
        ];
      };
    };

    stylix = {
      image = ../../../images/vortex.png;
      base16Scheme = "${npins.base16}/base16/mocha.yaml";

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
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
      };
    };
  };
}
