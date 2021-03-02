# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  nix.trustedUsers = [ "@wheel" "nixos" ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # networking
  networking = {
    dhcpcd.enable = false;
    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "148.251.102.93";
      prefixLength = 32;
    }];
    defaultGateway = "";
    nameservers = [ "1.1.1.1" ];
    localCommands = 
    ''

      ip route add "148.251.69.141" dev "eth0"
      ip route add default via "148.251.69.141" dev "eth0"

    '';
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    wget vim git tree
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.zsh.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "yes"; 
    authorizedKeysFiles = [ "/etc/nixos/authorized-keys" ];
  };

  services.tt-rss = {
    enable = true;
    auth = {
      autoCreate = true;
      autoLogin = true;
    };
    registration.enable = false;
    selfUrlPath = "https://rss.pherzog.xyz/";
    themePackages = with pkgs; [ tt-rss-theme-feedly ];
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  #networking.firewall.allowedUDPPorts = [  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

