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

    programs.steam.enable = lib.mkDefault true;
    phil.core.enableBluetooth = lib.mkDefault true;
    hardware.acpilight.enable = true;

    environment = {
      systemPackages = with pkgs; [
        brightnessctl
        powertop
        acpi
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

    sops.secrets.wifi-passwords = { };
    networking.wireless = {
      enable = true;
      #userControlled.enable = true;
      interfaces = cfg.wirelessInterfaces;
      environmentFile = config.sops.secrets.wifi-passwords.path;
      networks = {
        "BBC TV truck #20" = {
          psk = "@PSK_HOME@";
        };
      };
    };
  };
}

