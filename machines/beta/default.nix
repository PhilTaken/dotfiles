{
  modulesPath,
  lib,
  ...
}: let
  ip4_eth0 = "195.201.93.72/32";
  gateway_ip = "172.31.1.1";
in {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko-config.nix
  ];

  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "enp1s0";
    networkConfig.DHCP = "no";
    address = [ip4_eth0];
    routes = [
      {routeConfig.Destination = gateway_ip;}
      {
        routeConfig = {
          Gateway = gateway_ip;
          GatewayOnLink = true;
        };
      }
    ];
  };

  networking.useNetworkd = true;

  boot.initrd.availableKernelModules = ["xhci_pci" "virtio_pci" "virtio_scsi" "sr_mod"];
  boot.initrd.kernelModules = ["virtio_gpu"];
  boot.kernelParams = ["console=tty"];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "23.11";

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
