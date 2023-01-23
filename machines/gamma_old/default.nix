{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/a27887cb-766a-4024-bfaa-34843095ceab";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/2D6B-0360";
      fsType = "vfat";
    };

  fileSystems."/media/platte" =
    {
      device = "/dev/disk/by-uuid/1AEA5B14EA5AEC0F";
      fsType = "ntfs-3g";
      options = [ "defaults" "user" "rw" "utf8" "umask=000" "uid=1000" "gid=100" "exec" ];
    };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
