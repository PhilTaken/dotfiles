{ config, pkgs, lib, ... }:
{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };

    "/media" = {
      device = "/dev/disk/by-label/seagate";
      fsType = "ext4";
      options = [ "defaults" "user" "rw" "exec" ];
    };
  };


  # to fix the usb ssd adapter misbehaving due to poor uasp support >.>
  boot.kernelParams = [
    "usb-storage.quirks=152d:0578:u"
    "usbcore.quirks=152d:0578:u"
  ];
}
