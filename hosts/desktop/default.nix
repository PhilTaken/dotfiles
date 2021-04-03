{
  pkgs,
  inputs,
  username ? "nixos",
  hostname ? "worklaptop",
  timezone ? "Europe/Berlin",
  ...
}:
let
  usermod = (import (../../users + "/${username}" ) { inherit pkgs; }).hostDetails;
in {
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
        experimental-features = nix-command flakes
    '';
    autoOptimiseStore = true;
    trustedUsers = [ "root" "${username}" "@wheel" ];
  };
  users.users."${username}" = usermod;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [
     # intel-compute-runtime
     # intel-media-driver
     # vaapiVdpau
     # libvdpau-va-gl
    ];
  };
  hardware.enableRedistributableFirmware = true;

  virtualisation.docker.enable = true;

  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname;
  #networking.wireless.enable = true;
  #networking.wireless.userControlled.enable = true;
  #networking.wg-quick.interfaces = {
  #  mullvad = import ../vpn/mullvad.nix;
  #};

  # Set your time zone.
  time.timeZone = "${timezone}";

  # dhcp config
  #networking.useDHCP = false;
  #networking.interfaces.enp0s25.useDHCP = true;
  #networking.interfaces.enp4s0.useDHCP = true;

  services.connman = {
    enable = true;
    enableVPN = false;
    wifi.backend = "wpa_supplicant";
  };

  # Configure keymap in X11 and console
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "workman";
  console.useXkbConfig = true;

  # Enable sound.
  sound.enable = true;
  sound.mediaKeys.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
      gtkUsePortal = true;
    };
  };


  environment.systemPackages = with pkgs; [
    vim git          # defaults
    cryptsetup       # encrypted disks
    cmst             # connman system tray
    hwinfo
    #glxinfo
    #libva-utils
    #vpnc
    powertop
  ];
  services.udev.packages = with pkgs; [ yubikey-personalization ];

  programs.zsh.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  programs.light.enable = true;

  system.stateVersion = "20.09";
}
