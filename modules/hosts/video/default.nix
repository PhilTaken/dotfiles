{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.video;

  session_map = {
    "xfce" = "xfce";
    "kde" = "plasma";
    "gnome" = "gnome";
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

    driver = mkOption {
      description = "video driver";
      type = types.nullOr (types.enum [ "noveau" "nvidia" "amd" ]);
      default = null;
    };

    managers = mkOption {
      description = "which window/desktop manager to enable";
      type = types.listOf manager_enum;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config = mkIf (cfg.driver == "nvidia") {
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "nvidia-x11"
        "nvidia-settings"
      ];
    };

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    console.useXkbConfig = true;

    fonts.fonts = with pkgs; [
      iosevka-comfy.comfy
      font-awesome
      (nerdfonts.override {
        fonts = [
          "SourceCodePro"
          "Iosevka"
          "FiraCode"
          "FiraMono"
          "Hack"
        ];
      })
    ];

    # https://github.com/nix-community/home-manager/issues/2017
    # https://github.com/NixOS/nixpkgs/issues/158025
    programs.sway.enable = true;
    programs.hyprland.enable = true;
    # https://wiki.hyprland.org/Nix/#modules-mixnmatch
    #programs.hyprland.package = null;

    services.xserver =
      let
        enable = cfg.managers != [ ];
      in
      {
        inherit enable;
        layout = "us";
        xkbVariant = "intl,workman-intl";
        xkbOptions = "caps:escape,grp:shifts_toggle";

        videoDrivers = if (cfg.driver != null) then [ cfg.driver ] else [ ];

        displayManager = {
          #sddm.enable = enable;
          gdm.enable = true;
          defaultSession = session_map.${builtins.head cfg.managers};
        };

        screenSection = mkIf (cfg.driver == "nvidia") ''
          Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
          Option         "AllowIndirectGLXProtocol" "off"
          Option         "TripleBuffer" "on"
        '';

        libinput = { inherit enable; };

        desktopManager = {
          plasma5.enable = enabled "kde";
          xfce.enable = enabled "xfce";
          gnome.enable = enabled "gnome";
          xterm.enable = true;
        };
      };

    # ----------------------
    # gnome
    services.gnome.gnome-browser-connector.enable = enabled "gnome";
    services.gnome.gnome-keyring.enable = mkForce false;
    services.udev.packages = if (enabled "gnome") then [ pkgs.gnome.gnome-settings-daemon ] else [ ];
    services.dbus.packages = if (enabled "gnome") then [ pkgs.dconf ] else [ ];
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


    environment.systemPackages = with pkgs; [
      slurp
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
            };
          };
        };
        #gtkUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
          #xdg-desktop-portal-gtk
        ];
      };
    };
  };
}
