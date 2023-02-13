{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "cryptd" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "vfat" "nls_cp437" "nls_iso8859-1" "usbhid" ];
  boot.kernelModules = [ "kvm-amd" "zfs" ];
  boot.extraModulePackages = [ pkgs.zfs ];
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # https://nixos.wiki/wiki/OSX-KVM
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';

  virtualisation.libvirtd.enable = true;

  #boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  boot.supportedFilesystems = [ "zfs" ];

  # Enable support for the YubiKey PBA
  boot.initrd.luks.yubikeySupport = true;

  boot.initrd.luks.devices = {
    nixos-enc = {
      device = "/dev/disk/by-uuid/c31cf3c4-270c-46ad-b73c-c7a69acd11f1";
      preLVM = true;
      yubikey = {
        slot = 2;
        twoFactor = false;
        storage = {
          device = "/dev/disk/by-uuid/29B9-AA38";
        };
      };
    };
  };


  fileSystems = {
    "/" = {
      device = "rpool/root/nixos";
      fsType = "zfs";
    };

    "/home" = {
      device = "rpool/home";
      fsType = "zfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/29B9-AA38";
      fsType = "vfat";
    };

    "/media/platte" = {
      device = "/dev/disk/by-uuid/1AEA5B14EA5AEC0F";
      fsType = "ntfs-3g";
      options = [ "defaults" "user" "rw" "utf8" "umask=000" "uid=1000" "gid=100" "exec" ];
    };
  };

  swapDevices = [{
    device = "/dev/disk/by-uuid/d00d153a-b9f1-4ebb-8803-50dc8e532fa7";
  }];

  networking.hostId = "f95453f6";

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

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  phil.fileshare.mount.binds = [{
    host = "delta";
    dirs = [{ remote = "/media"; local = "/media/delta"; }];
  }];

  system.stateVersion = "23.05";

  home-manager.sharedModules = [{
    phil.wms.bars.eww.main_monitor = 1;
    services.kanshi = {
      profiles = {
        dual-monitor = {
          outputs = [
            {
              criteria = "Philips Consumer Electronics Company PHL 245E1 0x000072DC";
              mode = "2560x1440@74.968002";
              position = "0,1080";
            }
            {
              criteria = "WOR TERRA 2455W W507LSD00315";
              mode = "1920x1080@60.000000";
              position = "0,0";
            }
          ];
        };
      };
    };
  }];
}
