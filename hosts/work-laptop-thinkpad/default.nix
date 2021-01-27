{ 
  pkgs,
  inputs,
  username ? "nixos",
  hostname ? "worklaptop",
  timezone ? "Europe/Berlin",
  ... 
}:
let
  usermod = import (../../users + "/${username}" ) { inherit pkgs; };
in {
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
        experimental-features = nix-command flakes
    '';
    autoOptimiseStore = true;
    trustedUsers = [ "root" "${username}" "@wheel" ];
  };

  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname;
  networking.wireless.enable = true;
  networking.wg-quick.interfaces = {
    mullvad = import ../vpn/mullvad.nix;
  };

  # Set your time zone.
  time.timeZone = "${timezone}";

  # dhcp config
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # Configure keymap in X11 and console
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "workman";
  console.useXkbConfig = true;

  # Enable sound.
  sound.enable = true;
  sound.mediaKeys.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  users.users."${username}" = usermod;

  environment.systemPackages = with pkgs; [
    vim git
    cryptsetup
    #opensc
  ];
  #services.pcscd.enable = true;
  services.udev.packages = with pkgs; [ yubikey-personalization ];

  programs.zsh.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  programs.light.enable = true;

  #services.actkbd = {
  #  enable = true;
  #  bindings = [
  #    { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 10"; }
  #    { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 10"; }
  #  ];
  #};

  system.stateVersion = "20.09"; # Did you read the comment?
}
