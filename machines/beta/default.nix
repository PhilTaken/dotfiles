{ config, pkgs, lib, ... }:
{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  # to fix the usb ssd adapter misbehaving due to poor uasp support >.>
  boot.kernelParams = [
    "usb-storage.quirks=152d:0578:u"
    "usbcore.quirks=152d:0578:u"
  ];
}