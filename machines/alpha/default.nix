{ pkgs, ... }:
let
  lib = pkgs.lib;
  ip4_eth0 = "148.251.102.93";
in
rec {

  imports = [ ./hardware-configuration.nix ];

  #boot.loader.grub.device = "/dev/sda";

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

  # ---------------------------------------------------------------------:
  # TODO move all these to proper modules

  # local dns + secure dns
  #services.unbound = {
  #enable = true;
  #settings = {
  #server = {
  #interface = "127.0.0.1";
  #port = 5335;
  #do-ip4 = "yes";
  #do-udp = "yes";
  #do-tcp = "yes";
  #prefer-ip6 = "no";
  #harden-glue = "yes";
  #harden-dnssec-stripped = "yes";
  #use-caps-for-id = "no";
  #edns-buffer-size = 1472;
  #prefetch = "yes";
  #num-threads = 1;
  #so-rcvbuf = "1m";
  #};
  ## https://www.bentasker.co.uk/documentation/linux/279-unbound-adding-custom-dns-records
  ## https://wiki.archlinux.org/title/Unbound#Using_openresolv
  #local-data = [
  #"rss.pherzog.xyz A 127.0.0.1"
  #"adguard.pherzog.xyz A 127.0.0.1"

  #];
  #};
  #};

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

  services.innernet = {
    enable = true;
    config = builtins.readFile ../../../secret/vpn/valhalla.conf;
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
  services.nginx =
    let
      adguard = services.adguardhome;
      tt-rss = services.tt-rss;
    in
    {
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

      virtualHosts."adguard.pherzog.xyz" = lib.mkIf adguard.enable {
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
    } // (import ../../secret/vaultwarden.nix);
  };

  # minecraft server for testing
  services.minecraft-server = {
    enable = true;
    eula = true;
    declarative = true;

    serverProperties = {
      server-port = 25565;
      gamemode = "survival";
      motd = "NixOS Minecraft server on Tailscale!";
      max-players = 5;
      enable-rcon = true;
      "rcon.password" = "hunter2";
      level-seed = "10292992";
    };
  };
  nixpkgs.config.allowUnfree = true;

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
        53 # dns (adguard home)
        80 # tt-rss webinterface
        443 # tt-rss ssl
        51820 # innernet
        31111 # adguard home webinterface
        25565 # minecraft
      ];

      allowedUDPPorts = [
        53 # dns (adguard home)
        51820
        25565 # minecraft
      ];
    };

    "valhalla" = {
      allowedUDPPorts = [
        5353 # dns
        51820 # innernet
        25565 # minecraft
      ];

      allowedTCPPorts = [
        53 # dns (adguard home)
        80 # tt-rss webinterface
        443 # tt-rss ssl
        51820 # innernet
        31111 # adguard home webinterface
        25565 # minecraft
      ];
    };
  };

  system.stateVersion = "20.09";
}
