{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.video;
in
{
  options.phil.video = {
    enable = mkOption {
      description = "enable video module";
      type = types.bool;
      default = false;
    };

    driver = mkOption {
      description = "video driver";
      type = types.nullOr (types.enum [ "noveau" "nvidia" "amd" ]);
      default = null;
    };

    manager = mkOption {
      description = "which window/desktop manager to enable\nxfce is xfce+i3";
      type = (types.enum [ "kde" "sway" "i3" "xfce" "gnome" ]);
      default = "sway";
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
      #extraPackages = with pkgs; [
        #libva
        #vaapiVdpau
        #libvdpau-va-gl
        #mesa_drivers
      #];
    };

    services.xserver =
      let
        enable = (cfg.manager != "sway");
      in
      {
        inherit enable;
        layout = "us";
        xkbVariant = "workman-intl,intl";
        xkbOptions = "caps:escape,grp:shifts_toggle";

        displayManager = {
          gdm.enable = (cfg.manager == "gnome");
          defaultSession =
            if (cfg.manager == "i3") then "none+i3" else
            if (cfg.manager == "xfce") then "xfce+i3" else
            if (cfg.manager == "kde") then "plasma" else
            if (cfg.manager == "gnome") then "gnome" else
            null;
        };

        videoDrivers =
          if (cfg.driver != null) then [
            cfg.driver
          ] else [ ];

        screenSection = mkIf (cfg.driver == "nvidia") ''
          Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
          Option         "AllowIndirectGLXProtocol" "off"
          Option         "TripleBuffer" "on"
        '';

        libinput = {
          inherit enable;
        };

        desktopManager = {
          xfce = {
            enable = (cfg.manager == "xfce");
            noDesktop = true;
            enableXfwm = false;
          };
          plasma5.enable = (cfg.manager == "kde");
          gnome.enable = (cfg.manager == "gnome");
          xterm.enable = false;
        };

        windowManager.i3 = {
          enable = (cfg.manager == "i3" || cfg.manager == "xfce");
          package = pkgs.i3-gaps;
        };
      };

    console.useXkbConfig = true;


    fonts.fonts = with pkgs; [
      #iosevka-bin
      (nerdfonts.override {
        fonts = [
          "Iosevka"
          "FiraCode"
          "FiraMono"
          "Hack"
        ];
      })
    ];

    # ----------------------
    # gnome
    environment.systemPackages = if (cfg.manager == "gnome") then (with pkgs; [
      gnomeExtensions.appindicator
      networkmanager-vpnc
      gnome.networkmanager-vpnc
    ]) else [];

    services.udev.packages = if (cfg.manager == "gnome") then (with pkgs; [
      gnome3.gnome-settings-daemon
    ]) else [];

    services.gnome.chrome-gnome-shell.enable = (cfg.manager == "gnome");

    # ----------------------
    # kde

    # enable kdeconnect + open the required ports
    programs.kdeconnect.enable = (cfg.manager == "kde");
    networking.firewall =
      let
        kde_ports = builtins.genList (x: x + 1714) (1764 - 1714 + 1);
      in
      mkIf (cfg.manager == "kde") {
        allowedTCPPorts = kde_ports ++ [ 8888 ];
        allowedUDPPorts = kde_ports ++ [ 8888 ];
      };

    # ----------------------
    # sway

    programs.sway = {
      enable = (cfg.manager == "sway");
      wrapperFeatures.gtk = true;
    };

    services.greetd = mkIf (cfg.manager == "sway") {
      enable = true;
      settings = {
        default_session = {
          command = "${lib.makeBinPath [pkgs.greetd.tuigreet] }/tuigreet --time --cmd sway";
          user = "greeter";
        };
      };
    };
  };
}

