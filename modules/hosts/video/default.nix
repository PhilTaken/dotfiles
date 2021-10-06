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
      description = "which window/desktop manager to enable";
      type = (types.enum [ "kde" "sway" "i3" ]);
      default = "sway";
    };
  };

  config = mkIf (cfg.enable) {
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        libva
        vaapiVdpau
        libvdpau-va-gl
        mesa_drivers
      ];
    };

    services.xserver =
      let
        enable = (cfg.manager == "kde" || cfg.manager == "i3");
      in
      {
        inherit enable;
        layout = "us";
        xkbVariant = "workman-intl,intl";
        xkbOptions = "caps:escape,grp:shifts_toggle";

        displayManager = {
          defaultSession = "none+i3";
          #defaultSession = "plasma5";
        };

        videoDrivers =
          if (cfg.driver != null) then [
            cfg.video_driver
          ] else [ ];

        libinput = {
          inherit enable;
        };

        desktopManager = {
          plasma5.enable = (cfg.manager == "kde");
          xterm.enable = false;
        };

        windowManager.i3 = {
          enable = (cfg.manager == "i3");
          package = pkgs.i3-gaps;
        };
      };
    console.useXkbConfig = true;

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

    services.greetd = (mkIf cfg.manager == "sway") {
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

