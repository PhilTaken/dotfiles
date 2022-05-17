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
    "zfs.zfs_arc_max=134217728"
    "console=TTYAMA0,115200"
    "console=tty1"
    "8250.nr_uarts=1"
    "iomem=relaxed"
    "strict-devmem=0"
  ];

  # # A bunch of boot parameters needed for optimal runtime on RPi 4B
  # boot.kernelPackages = pkgs.linuxPackages_rpi4;

  # # pwm timers
  # boot.kernelModules = [ "pwm_bcm2835" "w1-gpio" ];

  # # Enable SATA-HAT GPIO features
  # #boot.loader.raspberryPi = {
  #   #enable = true;
  #   #version = 4;
  #   #firmwareConfig = ''
  #     #iomem=relaxed
  #     #strict-devmem=0
  #     #dtoverlay=pwm-2chan,pin=12,func=4,pin2=13,func2=4
  #     #dtoverlay=w1-gpio
  #     #dtparam=i2c1=on
  #   #'';
  # #};

  # # Load PWM hardware timers
  # hardware.deviceTree = {
  #   enable = true;
  #   #filter = "*-rpi-*.dtb";
  #   overlays = [
  #     {
  #       name = "pwm-2chan";
  #       dtboFile = "${pkgs.device-tree_rpi.overlays}/pwm-2chan.dtbo";
  #     }
  #     {
  #       name = "w1-gpio";
  #       dtboFile = "${pkgs.device-tree_rpi.overlays}/w1-gpio.dtbo";
  #     }
  #   ];
  # };

  # # Enable I2C
  # hardware.i2c.enable = true;

}
