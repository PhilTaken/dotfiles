{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "cryptd" "sr_mod"];
  boot.initrd.kernelModules = ["dm-snapshot" "vfat" "nls_cp437" "nls_iso8859-1" "usbhid"];
  boot.kernelModules = ["kvm-amd"];
  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  virtualisation.libvirtd.enable = true;
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;
  boot.plymouth.enable = true;

  networking.hostId = "f95453f6";

  # from hardware-configuration.nix
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  disko.devices = import ./disko-config.nix {
    disks = ["/dev/nvme0n1"];
  };

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

  phil.fileshare.mount.binds = [
    {
      host = "delta";
      dirs = [
        {
          remote = "/media";
          local = "/media/delta";
        }
      ];
    }
  ];

  system.stateVersion = "23.05";

  home-manager.sharedModules = [
    {
      phil.wms.bars.eww.main_monitor = 1;
      services.kanshi = {
        profiles = {
          dual-monitor = {
            outputs = [
              {
                criteria = "Philips Consumer Electronics Company PHL 245E1 0x000072DC";
                mode = "2560x1440@74.968002";
                position = "0,0";
              }
            ];
          };
        };
      };
    }
  ];
}
