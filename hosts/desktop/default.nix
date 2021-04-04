{
  pkgs,
  inputs,
  username ? "nixos",
  hostname ? "nix-desktop",
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

  hardware.enableRedistributableFirmware = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      libva
      vaapiVdpau
      libvdpau-va-gl
      mesa_drivers
    ];
  };
  #environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  virtualisation.docker.enable = true;

  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname;
  #networking.wg-quick.interfaces = {
    #mullvad = import ../vpn/mullvad.nix;
  #};

  # Set your time zone.
  time.timeZone = "${timezone}";

  # dhcp config
  #networking.useDHCP = false;
  #networking.interfaces.enp0s25.useDHCP = true;
  #networking.interfaces.enp4s0.useDHCP = true;

  # Configure keymap in X11 and console
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "workman";
  #services.xserver.enable = true;
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome3.enable = true;

  #nixpkgs.config.allowUnfree = true;
  #services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.videoDrivers = [ "nouveau" ];

  console.useXkbConfig = true;

  # Enable sound.
  sound.enable = true;
  sound.mediaKeys.enable = true;

  hardware.pulseaudio.enable = false;
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
    hwinfo
    glxinfo
    libva-utils
    powertop
  ];
  services.udev.packages = with pkgs; [ yubikey-personalization ];

  programs.zsh.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  system.stateVersion = "21.05";
}
