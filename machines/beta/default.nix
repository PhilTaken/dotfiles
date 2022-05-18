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
  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;

    kernelParams = [
      "usb-storage.quirks=152d:0578:u"
      "usbcore.quirks=152d:0578:u"
      "zfs.zfs_arc_max=134217728"
      "8250.nr_uarts=1"
      "console=TTYAMA0,115200"
      "console=tty1"
      "cma=128M"

      "iomem=relaxed"
      "strict-devmem=0"
    ];

    # ---------------------------------------------------------------
    # basically, everything after here is new, comment to revert back
    # ---------------------------------------------------------------

    # pwm timers
    kernelModules = [ "pwm_bcm2835" "w1-gpio" ];

    tmpOnTmpfs = true;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" ];

    #loader.raspberryPi = {
      #enable = true;
      #version = 4;
    #};
    #loader.grub.enable = false;
  };

  hardware.raspberry-pi."4".fkms-3d.enable = true;
  hardware.i2c.enable = true;

  # don't forget to add the user to the gpio group
  users.groups.gpio = {};

  services.udev.extraRules = ''
    SUBSYSTEM=="bcm2835-gpiomem", KERNEL=="gpiomem", GROUP="gpio",MODE="0660"
    SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio  /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
    SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add",RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value ; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
  '';

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
}
