{ pkgs
, inputs
, username ? "nixos"
, hostname ? "nix-desktop"
, timezone ? "Europe/Berlin"
, enable_xorg ? true
, ...
}:
let
  hostmod = (import (../../users + "/${username}") { inherit pkgs username; }).hostDetails;
  usermod = (import (../../users + "/${username}") { inherit pkgs username; }).userDetails;

  kde_ports = builtins.genList (x: x + 1714) (1764 - 1714 + 1);
in
rec {
  imports = [ ./hardware-configuration.nix ];
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    autoOptimiseStore = true;
    trustedUsers = [ "root" "${username}" "@wheel" ];
    #sandboxPaths = [ "/bin/sh=${pkgs.bash}/bin/sh" ];

    # TODO add my own registry
    registry = { };
  };
  hardware.enableRedistributableFirmware = true;
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname;
  time.timeZone = "${timezone}";

  #networking.wg-quick.interfaces = {
  #mullvad = import ../vpn/mullvad.nix;
  #};

  # dhcp config
  #networking.useDHCP = false;
  #networking.interfaces.enp0s25.useDHCP = true;
  #networking.interfaces.enp4s0.useDHCP = true;

  # Configure keymap in X11 and console
  services.xserver = {
    enable = enable_xorg;
    layout = "us";

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      #defaultSession = "none+i3";
      defaultSession = "plasma5";
    };

    videoDrivers = if enable_xorg then [ "nvidia" ] else [ "noveau" ];

    libinput.enable = enable_xorg;

    desktopManager.plasma5 = {
      enable = enable_xorg;
    };
  };
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

  services.udev.packages = with pkgs; [ yubikey-personalization ];
  services.tailscale.enable = true;
  services.sshd.enable = true;

  programs.zsh.enable = true;
  programs.mtr.enable = true;
  programs.command-not-found.enable = false;
  programs.zsh.interactiveShellInit = ''
    source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
  '';

  virtualisation.docker.enable = true;

  security.pam.yubico = {
    enable = true;
    #debug = true;
    mode = "challenge-response";
    challengeResponsePath = "/etc/yubipam/";
  };

  programs.sway = {
    enable = !enable_xorg;
    wrapperFeatures.gtk = true;
  };

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

  environment.etc = {
    "yubipam/${username}-14321676".source = usermod.pamfile;
  };

  #environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  networking.firewall.allowedTCPPorts = kde_ports ++ [ 8888 ];
  networking.firewall.allowedUDPPorts = kde_ports ++ [ 8888 ];

  # TODO add to extraconfig
  networking.firewall.interfaces = {
    "valhalla" = {
      allowedUDPPorts = [
        5353
      ];
    };
  };
  programs.steam.enable = true;

  system.stateVersion = "21.05";

  # --------------------------------------------------

  users.users."${username}" = hostmod;

}
