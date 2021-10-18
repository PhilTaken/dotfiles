{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.webapps;
in
{
  options.phil.webapps = {
    enable = mkOption {
      description = "enable webapps module";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) rec {
    sops.secrets.vaultwarden-adminToken = { };
    sops.secrets.vaultwarden-yubicoClientId = { };
    sops.secrets.vaultwarden-yubicoSecretKey = { };

    # TODO set up influxdb2
    # TODO move into separate modules

    # TODO finish unbound definitions
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

    # TODO enable for all systems
    # TODO convert to sops config scheme
    #services.innernet = {
    #enable = false;
    #config = builtins.readFile ../../../secret/vpn/valhalla.conf;
    # config:
    #  - listen-port: 51820
    #  - address: "10.42.0.1"
    #  - network-cidr-prefix: 16
    #interfaceName = "valhalla";
    #openFirewall = true;
    #};

    # dns ad blocking
    services.adguardhome = {
      enable = true;
      host = "http://127.0.0.1";
      port = 31111;
      openFirewall = false;
    };

    # TODO configure hedgedoc
    services.hedgedoc = {
      enable = false;
    };

    # TODO/WIP configure reverse proxy for all services
    # maybe switch to traefik / other
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

    # TODO configure nextcloud for small file hosting + floccus bookmark + browsersync
    # in container?
    services.nextcloud = {
      enable = false;
    };

    # TODO configure grafana
    services.grafana = {
      enable = false;
      port = 31112;
    };

    # TODO configure vaultwarden
    services.vaultwarden = {
      enable = false;
      config = {
        domain = "vault.pherzog.xyz";
        rocketPort = 31113;

        #rocketTls = "{certs=\"/path/to/certs.pem\",key=\"/path/to/key.pem\"}";
        signupsAllowed = true;
        rocketLog = "critical";

        yubicoClientId = config.sops.secrets.vaultwarden-yubicoClientId.path;
        yubicoSecretKey = config.sops.secrets.vaultwarden-yubicoSecretKey.path;
        adminToken = config.sops.secrets.vaultwarden-adminToken.path;
      };
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
  };
}

