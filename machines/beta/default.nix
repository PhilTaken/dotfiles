{ config, pkgs, lib, ... }:
{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  boot.extraModprobeConfig = /* modconf */ ''
    options usbcore quirks=152d:0578:u
    options usb-storage quirks=152d:0578:u
  '';
}
