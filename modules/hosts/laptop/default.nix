{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.laptop;
in {
  options.phil.laptop = {
    enable = mkEnableOption "laptop";
    low_power = mkEnableOption "low powered laptop";
  };

  config = mkIf cfg.enable {
    programs.steam.enable = lib.mkDefault false;
    phil.core.enableBluetooth = lib.mkDefault true;
    hardware.acpilight.enable = true;

    nix.distributedBuilds = true;
    nix.buildMachines = [];

    nix.extraOptions = lib.optionalString cfg.low_power ''
      max-jobs = 0
      builders-use-substitutes = true
    '';

    environment = {
      systemPackages = with pkgs; [
        brightnessctl
        acpi
        wpa_supplicant_gui
      ];
      sessionVariables.LIBVA_DRIVER_NAME = "iHD";
    };

    services.tlp = {
      enable = true;
      settings = {
        SATA_LINKPWR_ON_AC = "max_performance";
        SATA_LINKPWR_ON_BAT = "med_power_with_dipm";

        TLP_DEFAULT_MODE = "BAT";

        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";

        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";

        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;

        SCHED_POWERSAVE_ON_AC = 0;
        SCHED_POWERSAVE_ON_BAT = 1;

        DEVICES_TO_ENABLE_ON_STARTUP = "wifi";
      };
    };

    powerManagement = {
      enable = true;
      cpuFreqGovernor = "powersave";
      powertop.enable = true;
    };

    programs.light.enable = true;
    services.xserver.libinput.touchpad.accelProfile = "flat";

    services.udev.packages = builtins.attrValues {
      inherit (pkgs) qmk-udev-rules;
    };

    networking.networkmanager.enable = true;
  };
}
