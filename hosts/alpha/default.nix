# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, ... }: let
  lib = pkgs.lib;
  ip4_eth0 = "148.251.102.93";
in rec {
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
      address = ip4_eth0;
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

  # ---------------------------------------------------- #

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "yes";
    authorizedKeysFiles = [ "/etc/nixos/authorized-keys" ];
  };

  #services.avahi = {
    #enable = true;
    #interfaces = [
      #"valhalla"
    #];

    #nssmdns = true;
    #domainName = "pherzog.xyz";

    #allowPointToPoint = true;

    #publish = {
      #enable = true;
      #domain = true;
      #addresses = true;
      #userServices = true;
    #};

    #extraServiceFiles = {
      #ssh = "${pkgs.avahi}/etc/avahi/services/ssh.service";
    #};
  #};

  # local dns + secure dns
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = "127.0.0.1";
        port = 5335;
        do-ip4 = "yes";
        do-udp = "yes";
        do-tcp = "yes";
        prefer-ip6 = "no";
        harden-glue = "yes";
        harden-dnssec-stripped = "yes";
        use-caps-for-id = "no";
        edns-buffer-size = 1472;
        prefetch = "yes";
        num-threads = 1;
        so-rcvbuf = "1m";
      };
      # https://www.bentasker.co.uk/documentation/linux/279-unbound-adding-custom-dns-records
      # https://wiki.archlinux.org/title/Unbound#Using_openresolv
      local-data = [
        "rss.pherzog.xyz A 127.0.0.1"
        "adguard.pherzog.xyz A 127.0.0.1"

      ];
    };
  };

  # acme security (lets encrypt)
  security.acme = {
    email = "philipp.herzog@protonmail.com";
    acceptTerms = true;
  };

  # ---------------------------------------------------- #

  # rss client
  services.tt-rss = {
    enable = true;
    auth = {
      autoCreate = true;
      autoLogin = true;
    };
    registration.enable = false;
    selfUrlPath = "https://rss.pherzog.xyz";
    virtualHost = "rss.pherzog.xyz";

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
    host = "http://127.0.0.1";
    port = 31111;
    openFirewall = false;
  };

  services.fail2ban.enable = true;

  # timescale db -> postgres
  # TODO replace with influxdb2
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
  services.nginx = let
    adguard = services.adguardhome;
    tt-rss = services.tt-rss;
  in {
    enable = true;
    #recommendedProxySettings = true;
    #recommendedTlsSettings = true;
    # other Nginx options
    virtualHosts."rss.pherzog.xyz" = {
      # supplied by tt-rss config
      # just a stub
      #enableACME = true;
      #forceSSL = true;
    };

    virtualHosts."adguard.pherzog.xyz" =  lib.mkIf adguard.enable {
      locations."/" = {
        proxyPass = "http://127.0.0.1:31111/";
      };
    };
  };

  # TODO for small file hosting + floccus bookmark + browsersync
  services.nextcloud = {
    enable = false;
  };

  # TODO grafana graphing service
  services.grafana = {
    enable = false;
    port = 31112;
  };

  # TODO bitwarden selfhosted instance
  services.vaultwarden = {
    enable = false;
    config = {
      domain = "vault.pherzog.xyz";
      rocketPort = 31113;

      #rocketTls = "{certs=\"/path/to/certs.pem\",key=\"/path/to/key.pem\"}";
      signupsAllowed = true;
      rocketLog = "critical";
    } // (import ../../hosts/secret/vaultwarden.nix);
  };

  # firewall
  networking.firewall.interfaces = {
    "eth0" = {
      allowedTCPPorts = [
        #80    # to get certs (let's encrypt)
        #443   # ---- " ----
      ];
    };

    "tailscale0" = {
      allowedTCPPorts = [
        53    # dns (adguard home)
        80    # tt-rss webinterface
        443   # tt-rss ssl
        51820
        31111 # adguard home webinterface
      ];

      allowedUDPPorts = [
        53    # dns (adguard home)
        51820
      ];
    };

    #"valhalla" = {
      #allowedUDPPorts = [
        #5353
        #51820
      #];

      #allowedTCPPorts = [
        #53    # dns (adguard home)
        #80    # tt-rss webinterface
        #443   # tt-rss ssl
        #51820
        #31111 # adguard home webinterface
      #];
    #};
  };

  system.stateVersion = "20.09";
}
