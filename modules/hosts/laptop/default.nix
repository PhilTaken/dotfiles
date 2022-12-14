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

    low_power = mkEnableOption "low powered laptop";
  };

  config = mkIf cfg.enable {
    sops.secrets.nix-remote-sshkey = { };

    programs.steam.enable = lib.mkDefault true;
    phil.core.enableBluetooth = lib.mkDefault true;
    hardware.acpilight.enable = true;

    nix.distributedBuilds = true;
    nix.buildMachines = [{
      sshUser = "nixos";
      hostName = "10.200.0.5";
      systems = [ "x86_64-linux" "i686-linux" ];
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUFPaHBOYm56ekt1em91SUoxMjNDa3VDNFJPRXp3cWhDbmJPVGVUeXF1N1Ygcm9vdEBkZWx0YQo=";
      sshKey = config.sops.secrets.nix-remote-sshkey.path;
    }];

    nix.extraOptions = lib.optionalString cfg.low_power ''
      max-jobs = 0
      builders-use-substitutes = true
    '';

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

    services.tlp.enable = true;

    sops.secrets.wifi-passwords = { };
    networking.wireless = {
      enable = true;
      userControlled.enable = true;
      interfaces = cfg.wirelessInterfaces;
      environmentFile = config.sops.secrets.wifi-passwords.path;
      networks = {
        "BBC TV truck #20" = {
          psk = "@PSK_HOME@";
        };
        "TALKTALK9738BE" = {
          psk = "@PSK_JAID@";
        };
        "TALKTALKD69C48" = {
          psk = "@PSK_VAC@";
        };
      };
    };
  };
}
