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

  #virtualisation.docker.enable = true;

  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname;
  networking.usePredictableInterfaceNames = false;
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;
  systemd.network = {
    enable = true;
    networks."eth0".extraConfig = ''
      [Match]
      name = eth0
      [Network]
      Address = 148.251.102.93
      Gateway = 148.251.69.141
    '';
  };

  # Set your time zone.
  time.timeZone = "${timezone}";

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

  users.users."${username}" = usermod;

  environment.systemPackages = with pkgs; [
    vim git          # defaults
    cryptsetup       # encrypted disks
    cmst             # connman system tray
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
