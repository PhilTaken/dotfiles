{
  pkgs,
  inputs,
  username ? "nixos",
  hostname ? "worklaptop",
  timezone ? "Europe/Berlin",
  enable_xorg ? false,
  ...
}:
let
  hostmod = (import (../../users + "/${username}" ) { inherit pkgs username; }).hostDetails;
  usermod = (import (../../users + "/${username}" ) { inherit pkgs username; }).userDetails;
in rec {
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
        experimental-features = nix-command flakes
    '';
    autoOptimiseStore = true;
    trustedUsers = [ "root" "${username}" "@wheel" ];
  };
  users.users."${username}" = hostmod;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  hardware.enableRedistributableFirmware = true;
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  virtualisation.docker.enable = true;

  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname;
  networking.tempAddresses = "enabled";
  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    interfaces = [ "wlp0s20f3" ];
  };

  networking.wg-quick.interfaces = {
    mullvad = import ../vpn/mullvad.nix;
  };

  # Set your time zone.
  time.timeZone = "${timezone}";

  # dhcp config
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  services.connman = {
    enable = true;
    enableVPN = false;
    wifi.backend = "wpa_supplicant";
  };

  # Configure keymap in X11 and console
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
  services.xserver = {
    enable = enable_xorg;
    layout = "us";
    xkbVariant = "workman-intl,intl";
    xkbOptions = "caps:escape,grp:shifts_toggle";

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      defaultSession = "none+i3";
    };

    libinput.enable = enable_xorg;
    libinput.touchpad.accelProfile = "flat";
    windowManager.i3 = {
      enable = enable_xorg;
      package = pkgs.i3-gaps;
    };
  };
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
    glxinfo
    libva-utils
    vpnc
    powertop
    nix-index
  ];

  # TODO set this up in the office
  environment.etc = {
    "yubipam/${username}-14321676".source = usermod.pamfile;
  };

  services.udev = {
    packages = with pkgs; [
      yubikey-personalization
    ];
    extraRules = builtins.readFile ./50-qmk.rules;
  };


  programs.zsh.enable = true;
  programs.light.enable = true;
  programs.sway = {
    enable = !enable_xorg;
    wrapperFeatures.gtk = true;
  };
  programs.mtr.enable = true;

  # add tailscale
  services.tailscale = {
    enable = true;
  };

  security.pam.yubico = {
    enable = true;
    debug = true;
    mode = "challenge-response";
    #challengeResponsePath = "/etc/yubipam/";
  };

  programs.command-not-found.enable = false;
  programs.zsh.interactiveShellInit = ''
    source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
  '';

  system.stateVersion = "21.05";
}
