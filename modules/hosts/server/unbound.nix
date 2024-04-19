{
  config,
  lib,
  net,
  flake,
  ...
}: let
  # TODO move dns to shiver via service discovery
  inherit (lib) mkEnableOption mkIf mkOption types;
  nodes = lib.filterAttrs (n: _v: builtins.hasAttr n net.networks.default.hosts) flake.nixosConfigurations;

  cfg = config.phil.server.services.unbound;
  iplot = net.networks.default.hosts;
  hostnames = builtins.attrNames iplot;
  mkDnsBindsFromServices = services:
    builtins.mapAttrs
    (_: builtins.head)
    (lib.zipAttrs
      (builtins.map
        (host:
          builtins.listToAttrs (builtins.map
            (service: let
              name = config.phil.server.services.${service}.host or service;
              value = host;
            in {inherit name value;})
            services.${host}))
        (builtins.attrNames services)));

  # TODO better handling of the default value
  ipForHost = network: host:
    if builtins.hasAttr host net.networks.${network}.hosts
    then net.networks.${network}.hosts.${host}
    else net.endpoints.alpha;

  subdomains =
    builtins.mapAttrs
    (network: _: builtins.mapAttrs (_app: host: ipForHost network host) cfg.apps)
    (lib.filterAttrs (n: _v: ! builtins.elem n ["default"]) net.networks);

  default_apps = let
    getProxiesFromHost = _: v: (builtins.attrNames v.config.phil.server.services.caddy.proxy);
    validHosts = lib.filterAttrs (_: v: lib.hasAttrByPath ["config" "phil" "server" "services" "caddy" "proxy"] v) nodes;
    allProxies = lib.mapAttrs getProxiesFromHost validHosts;
  in
    mkDnsBindsFromServices allProxies;
in {
  options.phil.server.services.unbound = {
    enable = mkEnableOption "enable the unbound server";

    apps = mkOption {
      description = "";
      type = types.attrsOf (types.enum hostnames);
      example = {
        "jellyfin" = "beta";
      };
      default = default_apps;
    };

    host = mkOption {
      type = types.str;
      default = "dns";
    };
  };

  # TODO: enable condition
  config = mkIf cfg.enable {
    networking.firewall = {
      allowedUDPPorts = [53 853];
      allowedTCPPorts = [53 853];
    };

    phil.server.services.caddy.proxy."${cfg.host}" = {port = 853;};

    services.unbound = let
      mkLocalData = lib.mapAttrsToList (name: value: "\"${name}.${net.tld}. IN A ${value}\"");
      mkLocalDataPtr = lib.mapAttrsToList (host: ip: "\"${ip} ${host}.${net.tld}\"");
    in {
      enable = true;

      # allow access to tls certs
      user = "nginx";

      settings = {
        include = "${./unbound-adblock.conf}";
        server = {
          access-control = [
            "127.0.0.0/8 allow" # localhost
            "10.100.0.1/24 allow" # yggdrasil
            "10.200.0.1/24 allow" # milkyway
            "192.168.0.1/16 allow" # local nets
          ];

          interface = [
            "0.0.0.0@53"
            "::0@53"
            "0.0.0.0@853"
            "::0@853"
          ];

          # tls upstream
          tls-upstream = "yes";
          tls-service-key = "${config.security.acme.certs."${cfg.host}.${net.tld}".directory}/key.pem"; # -> .key
          tls-service-pem = "${config.security.acme.certs."${cfg.host}.${net.tld}".directory}/cert.pem"; # -> .crt

          # tls downstream
          tls-cert-bundle = "/etc/ssl/certs/ca-certificates.crt";

          do-udp = "yes";
          do-tcp = "yes";
          do-ip4 = "yes";
          do-ip6 = "yes";

          # privacy + performance
          qname-minimisation = "yes"; # increase client privacy
          hide-identity = "yes";
          hide-version = "yes";
          harden-glue = "yes";
          harden-dnssec-stripped = "yes";
          use-caps-for-id = "no";
          cache-min-ttl = 3600;
          cache-max-ttl = 86400;
          incoming-num-tcp = 1000;
          prefetch = "yes";

          # performance
          rrset-cache-size = "256m";
          msg-cache-size = "128m";
          so-rcvbuf = "425984";
          so-reuseport = "yes";
          val-clean-additional = "yes";

          # block nasty ads
          local-zone = [
            "\"doubleclick.net\" redirect"
            "\"googlesyndication.com\" redirect"
            "\"googleadservices.com\" redirect"
            "\"google-analytics.com\" redirect"
            "\"ads.youtube.com\" redirect"
            "\"adserver.yahoo.com\" redirect"

            "\"${net.tld}.\" static"
          ];

          local-data =
            [
              "\"doubleclick.net A 127.0.0.1\""
              "\"googlesyndication.com A 127.0.0.1\""
              "\"googleadservices.com A 127.0.0.1\""
              "\"google-analytics.com A 127.0.0.1\""
              "\"ads.youtube.com A 127.0.0.1\""
              "\"adserver.yahoo.com A 127.0.0.1\""
            ]
            ++ mkLocalData subdomains.lan;

          local-data-ptr = mkLocalDataPtr subdomains.lan;

          # Specify custom local answers for each interface by using views:
          access-control-view = [
            "10.100.0.0/24 wg"
            "10.200.0.0/24 nebula"
            "192.168.0.0/16 lan"
            "127.0.0.0/8 nebula"
          ];
        };

        view = [
          {
            name = "\"lan\"";
            view-first = "yes";
            local-data = mkLocalData subdomains.lan;
            local-data-ptr = mkLocalDataPtr subdomains.lan;
          }

          {
            name = "\"wg\"";
            view-first = "yes";
            local-data = mkLocalData subdomains.yggdrasil;
            local-data-ptr = mkLocalDataPtr subdomains.yggdrasil;
          }

          {
            name = "\"nebula\"";
            view-first = "yes";
            local-data = mkLocalData subdomains.milkyway;
            local-data-ptr = mkLocalDataPtr subdomains.milkyway;
          }
        ];

        # downstream dns resolver
        forward-zone = [
          {
            name = ".";
            forward-tls-upstream = "yes"; # use dns over tls forwarder
            forward-addr = [
              "1.1.1.1@853#cloudflare-dns.com"
              "2a0e:dc0:6:23::2@853#dot-ch.blahdns.com"
              "2a01:4f8:151:34aa::198@853#dnsforge.de"
              "2001:678:e68:f000::@853#dot.ffmuc.net"
              "2a05:fc84::42@853#dns.digitale-gesellschaft.ch"
            ];
          }
        ];
      };
    };
  };
}
