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

  config = mkIf (cfg.enable) {
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
          gdm.enable = true;
          gdm.wayland = false;
          defaultSession = mkIf (builtins.length cfg.managers > 0) session_map.${builtins.head cfg.managers};
        };

        screenSection = mkIf (cfg.driver == "nvidia") ''
          Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
          Option         "AllowIndirectGLXProtocol" "off"
          Option         "TripleBuffer" "on"
        '';

        libinput = { inherit enable; };

        desktopManager = {
          xfce = {
            enable = enabled "xfce";
            noDesktop = true;
            enableXfwm = false;
          };
          plasma5.enable = enabled "kde";
          gnome.enable = enabled "gnome";
          xterm.enable = false;
        };
      };

    # ----------------------
    # gnome
    services.gnome.chrome-gnome-shell.enable = (enabled "gnome");
    services.udev.packages = if (enabled "gnome") then [ pkgs.gnome3.gnome-settings-daemon ] else [ ];
    services.dbus.packages = if (enabled "gnome") then [ pkgs.dconf ] else [ ];

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
  };
}
