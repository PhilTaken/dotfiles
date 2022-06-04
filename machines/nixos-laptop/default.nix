{ config
, lib
, modulesPath
, pkgs
, ...
}:
rec {
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/d2ef9ea1-0f23-4484-b1b2-a865b9664ea9";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/90CD-EFF9";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/292296da-5351-4563-86d3-5c332274d872"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # -----------------------------------------------------------------------------------------------------

  networking.tempAddresses = "enabled";

  # dhcp config
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;
  environment.systemPackages = [ pkgs.vpnc ];

  # -----------------------------------------------------------------------------------------------------
  # TODO move to keyboard ( qmk ?) module

  services.udev = {
    extraRules = builtins.readFile ./50-qmk.rules;
  };

  system.stateVersion = "21.05";
}
