{
  config,
  lib,
  flake,
  netlib,
  ...
}: let
  # TODO move dns to shiver via service discovery
  inherit (lib) mkEnableOption mkIf mkOption types;
  cfg = config.phil.server.services.unbound;
  net = config.phil.network;

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
  ipForHost = network: host: net.nodes.${host}.network_ip.${network} or net.nodes.beta.public_ip;

  subdomains =
    builtins.mapAttrs
    (network: _: builtins.mapAttrs (_app: host: ipForHost network host) cfg.apps)
    net.networks;

  default_apps = let
    getProxiesFromHost = n: _: (builtins.attrNames flake.nixosConfigurations.${n}.config.phil.server.services.caddy.proxy);
    allProxies = builtins.mapAttrs getProxiesFromHost net.nodes;
  in
    mkDnsBindsFromServices allProxies;
in {
  options.phil.server.services.unbound = {
    enable = mkEnableOption "enable the unbound server";

    apps = mkOption {
      description = "";
      type = types.attrsOf (types.enum (builtins.attrNames net.nodes));
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
    assertions = [
      {
        assertion = !config.services.resolved.enable;
        message = "cannot run both systemd-resolved and unbound";
      }
    ];

    networking.firewall = {
      allowedUDPPorts = [53 853];
      allowedTCPPorts = [53 853];
    };

    phil.server.services.caddy.proxy."${cfg.host}" = {port = 853;};

    users.users.unbound.extraGroups = ["nginx"];

    services.unbound = let
      mkLocalData = lib.mapAttrsToList (name: value: "\"${netlib.domainFor name}. IN A ${value}\"");
      mkLocalDataPtr = lib.mapAttrsToList (host: ip: "\"${ip} ${netlib.domainFor host}\"");
    in {
      enable = true;

      # enable metric collection through the prometheus exporter
      localControlSocketPath = "/run/unbound.ctl";

      settings = {
        include = "${./unbound-adblock.conf}";
        server = {
          # more stats for the prometheus exporter
          extended-statistics = "yes";

          # allow access from all defined internal networks
          access-control = lib.mapAttrsToList (_n: v: v.netmask + " allow") net.networks;
          interface = ["0.0.0.0@53" "::0@53" "0.0.0.0@853" "::0@853"];

          # tls upstream
          tls-upstream = "yes";
          tls-service-key = "${config.security.acme.certs."${net.tld}".directory}/key.pem"; # -> .key
          tls-service-pem = "${config.security.acme.certs."${net.tld}".directory}/cert.pem"; # -> .crt

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
          access-control-view = lib.mapAttrsToList (_n: v: v.netmask + " " + v.name) net.networks;
        };

        view =
          lib.mapAttrsToList (_n: v: {
            name = "\"${v.name}\"";
            view-first = "yes";
            local-data = mkLocalData subdomains.${v.name};
            local-data-ptr = mkLocalDataPtr subdomains.${v.name};
          })
          net.networks;

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
