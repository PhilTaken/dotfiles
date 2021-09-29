{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.template;
in
{
  options.phil.template = {
    enable = mkOption {
      description = "enable template module";
      type = types.bool;
      default = false;
    };

    driver = mkOption {
      description = "video driver";
      type = types.nullOr types.str;
      default = null;
    };

    enable_xorg = mkOption {
      description = "wether to enable the x graphical server";
      type = types.bool;
      default = false;
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

    services.xserver = {
      enable = cfg.enable_xorg;
      layout = "us";

      desktopManager = {
        xterm.enable = false;
      };

      #displayManager = {
      ##defaultSession = "none+i3";
      #defaultSession = "plasma5";
      #};

      videoDrivers =
        if (cfg.driver != null) then [
          cfg.video_driver
        ] else [ ];

      libinput.enable = cfg.enable_xorg;

      # TODO better config for plasma/i3 switching
      desktopManager.plasma5 = {
        enable = cfg.enable_xorg;
      };
    };

    # enable kdeconnect + open the required ports
    programs.kdeconnect.enable = cfg.enable_xorg;

    # TODO better config for sway enable
    programs.sway = {
      enable = !cfg.enable_xorg;
      wrapperFeatures.gtk = true;
    };

    console.useXkbConfig = true;
  };
}

