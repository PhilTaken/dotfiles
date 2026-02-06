{
  lib,
  pkgs,
  inputs,
  modulesPath,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    #(modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    supportedFilesystems = lib.mkForce [
      "vfat"
      "btrfs"
      "tmpfs"
    ];
    kernelParams = [
      "cgroup_enable=cpuset"
      "cgroup_memory=1"
      "cgroup_enable=memory"
    ];
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
  ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [ "compress=zstd" ];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [
      "noatime"
      "subvol=swap"
    ];
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  networking.networkmanager.wifi.powersave = false;

  # sdImage.compressImage = false;

  networking.hostId = "eb87404c";
  system.stateVersion = "25.05";

  # test single-node k3s
  # networking.firewall.allowedTCPPorts = [
  #   6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
  #   # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
  #   # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  # ];
  # networking.firewall.allowedUDPPorts = [
  #   # 8472 # k3s, flannel: required if using multi-node for inter-node networking
  # ];
  # services.k3s = {
  #   enable = true;
  #   role = "server";
  #   extraFlags = toString [
  #     # "--debug" # Optionally add additional args to k3s
  #   ];
  # };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
