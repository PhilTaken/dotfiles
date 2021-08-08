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
    hostName = "alpha";
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
    wget
    vim
    git
    tree
    fail2ban
    htop
  ];

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.zsh.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "yes";
    authorizedKeysFiles = [ "/etc/nixos/authorized-keys" ];
  };

  # rss client
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

  services.tailscale = {
    enable = true;
  };

  services.innernet = {
    enable = true;
    config = builtins.readFile ../vpn/valhalla.conf;
    interfaceName = "valhalla";
    openFirewall = true;
  };

  # dns ad blocking
  services.adguardhome = {
    enable = true;
    port = 31111;
    openFirewall = true;
  };

  services.fail2ban.enable = true;

  # timescale db -> postgres
  # TODO get this to work again
  #services.postgresql = {
    #extraPlugins = [ pkgs.timescaledb ];
    #settings = {
      #shared_preload_libraries = "timescaledb";
    #};
  #};

  # TODO online markdown editor
  services.hedgedoc = {
    enable = false;
  };

  # TODO reverse proxy for all services
  services.traefik = {
    enable = false;
  };

  # TODO for small file hosting + floccus bookmark + browsersync
  services.nextcloud = {
    enable = false;
  };

  # TODO grafana graphing service
  services.grafana = {
    enable = false;
  };

  # TODO bitwarden selfhosted instance
  services.vaultwarden = {
    enable = false;
  };

  # firewall
  networking.firewall.allowedTCPPorts = [
    53    # dns
    80    # tt-rss webinterface
    443   # tt-rss ssl
  ];

  networking.firewall.allowedUDPPorts = [
    53    # dns
  ];

  system.stateVersion = "20.09";
}

