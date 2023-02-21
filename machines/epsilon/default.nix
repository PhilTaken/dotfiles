{ config
, lib
, modulesPath
, pkgs
#, inputs
, ...
}:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
#      inputs.disko.nixosModules.disko
    ];

  disko.devices = import ./disko-config.nix {
    disks = ["/dev/sda"];
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  #boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_latest;
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.plymouth.enable = true;

  #nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # -----------------------------------------------------------------------------------------------------
  # TODO move to keyboard ( qmk ?) module

  services.udev = {
    extraRules = builtins.readFile ./50-qmk.rules;
  };

  services.fstrim.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
