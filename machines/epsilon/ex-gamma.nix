{
  config,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "cryptd"];
  boot.initrd.kernelModules = ["dm-snapshot" "vfat" "nls_cp437" "nls_iso8859-1" "usbhid"];
  boot.kernelModules = ["kvm-intel" "zfs"];
  boot.extraModulePackages = [pkgs.zfs];
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  boot.supportedFilesystems = ["zfs"];
  networking.hostId = "9cdfd6d0";

  #boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;

  # Enable support for the YubiKey PBA
  boot.initrd.luks.yubikeySupport = true;

  nixpkgs.overlays = [
    (_self: super: {
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
        #allowDiscards = true;
        yubikey = {
          slot = 2;
          twoFactor = false;
          storage = {
            device = "/dev/disk/by-uuid/FCA6-23E6";
          };
        };
      };
    };
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0fe85749-ef71-4106-acba-d996cac7032a";
    fsType = "ext4";
    options = ["noatime" "nodiratime" "discard"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FCA6-23E6";
    fsType = "vfat";
  };

  swapDevices = [{device = "/dev/disk/by-uuid/3e5936d8-03a3-48be-b03d-a9b5495fccdf";}];

  system.stateVersion = "21.05";
}
