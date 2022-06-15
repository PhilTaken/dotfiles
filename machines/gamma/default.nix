{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "cryptd" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;

  nixpkgs.overlays = [
    (self: super: {
      vlc = super.vlc.override {
        libbluray = super.libbluray.override {
          withAACS = true;
          withBDplus = true;
        };
      };
    })
  ];

  boot.initrd.luks = {
    devices = {
      luksroot = {
        device = "/dev/disk/by-uuid/5172d21f-b40d-4dd7-8d31-c1521ed54e46";
        preLVM = true;
        allowDiscards = true;
      };
    };
  };
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/0fe85749-ef71-4106-acba-d996cac7032a";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" "discard" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/FCA6-23E6";
      fsType = "vfat";
    };

  fileSystems."/platte" =
    {
      device = "/dev/disk/by-uuid/1AEA5B14EA5AEC0F";
      fsType = "ntfs-3g";
      options = [ "defaults" "user" "rw" "utf8" "umask=000" "uid=1000" "gid=100" "exec" ];
    };


  swapDevices =
    [{ device = "/dev/disk/by-uuid/3e5936d8-03a3-48be-b03d-a9b5495fccdf"; }];

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;

  phil.fileshare.mount.binds = [{
    host = "beta";
    dirs = [ "/mnt/media" ];
  }];

  system.stateVersion = "21.05";
}
