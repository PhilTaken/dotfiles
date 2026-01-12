{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # TODO reenable when twisted is fixed
  # or rewrite it in a sane language ...
  phil.server.services.promexp.extrasensors = false;

  # https://nixos.wiki/wiki/ZFS
  boot.kernelParams = [ "zfs.zfs_arc_max=12884901888" ];
  services.zfs.autoScrub.enable = true;

  boot.initrd.supportedFilesystems = [
    "zfs"
    "btrfs"
  ];
  boot.supportedFilesystems = [
    "zfs"
    "btrfs"
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  '';
  services.btrfs.autoScrub.enable = true;

  networking.hostId = "ef45f308";

  system.stateVersion = "22.05";
}
