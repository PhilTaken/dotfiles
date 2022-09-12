{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.laptop;
in
{
  options.phil.laptop = {
    enable = mkOption {
      description = "enable laptop module";
      type = types.bool;
      default = false;
    };

    # "wlp0s20f3" for nixos-laptop
    wirelessInterfaces = mkOption {
      description = "list of wireless interfaces";
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;

    phil.core.enableBluetooth = true;

    hardware.acpilight.enable = true;
    environment = {
      systemPackages = with pkgs; [
        brightnessctl
        powertop
        cmst # connman system tray
      ];
      sessionVariables.LIBVA_DRIVER_NAME = "iHD";
    };

    programs.light.enable = true;
    services.xserver.libinput.touchpad.accelProfile = "flat";

    services.udev.packages = with pkgs; [ qmk-udev-rules ];

    services.connman = {
      enable = true;
      enableVPN = false;
      wifi.backend = "wpa_supplicant";
    };

    networking.wireless = {
      enable = true;
      userControlled.enable = true;
      interfaces = cfg.wirelessInterfaces;
    };
  };
}

