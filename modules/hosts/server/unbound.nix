{ pkgs
, config
, lib
, net
, flake
, ...
}:
# TODO: dns over tls
let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.phil.server.services.unbound;
  iplot = net.networks.default;
  hostnames = builtins.attrNames iplot;
  mkDnsBindsFromServices = services: builtins.mapAttrs
    # TODO: sensible handling of identical services on multiple hosts
    (_: builtins.head)
    (lib.zipAttrs
      (builtins.map
        (host: builtins.listToAttrs (builtins.map
          (service:
            let
              name = config.phil.server.services.${service}.host or service;
              value = host;
            in
            { inherit name value; })
          # TODO: filter unbound?
          #(builtins.filter (elem: elem != "unbound") services.${host})))
          services.${host}))
        (builtins.attrNames services)));
in
{
  options.phil.server.services.unbound = {
    enable = mkEnableOption "enable the unbound server";

    apps = mkOption {
      description = "";
      type = types.attrsOf (types.enum hostnames);
      example = {
        "jellyfin" = "beta";
      };
      default = let
        getProxiesFromHost = _: v: (builtins.attrNames v.config.phil.server.services.caddy.proxy);
        validHosts = lib.filterAttrs (_: v: lib.hasAttrByPath [ "config" "phil" "server" "services" "caddy" "proxy" ] v) flake.nixosConfigurations;
        allProxies = lib.mapAttrs getProxiesFromHost validHosts;
      in mkDnsBindsFromServices allProxies;
    };

    host = mkOption {
      type = types.str;
      default = "dns";
    };
  };

  # TODO: enable condition
  config = mkIf cfg.enable {
    networking.firewall = {
      allowedUDPPorts = [ 53 853 ];
      allowedTCPPorts = [ 53 853 ];
    };

    phil.server.services.caddy.proxy."${cfg.host}" = { port = 853; };

    services.unbound =
      let
        subdomains = builtins.mapAttrs (name: value: { ip = iplot."${value}"; }) cfg.apps;
      in
      {
        enable = true;

        # allow access to tls certs
        user = "caddy";

        settings = {
          server = {
            access-control = [
              "127.0.0.0/8 allow" # localhost
              "10.100.0.1/24 allow" # yggdrasil
              "10.200.0.1/24 allow" # milkyway
              "192.168.0.1/24 allow" # local net
            ];

            interface = [
              "0.0.0.0@53"
              "::0@53"
              "0.0.0.0@853"
              "::0@853"
            ];

            # tls upstream
            tls-upstream = "yes";
            tls-service-key = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/dns.${net.tld}/dns.${net.tld}.key"; # -> .key
            tls-service-pem = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/dns.${net.tld}/dns.${net.tld}.crt"; # -> .crt

            # tls downstream
            tls-cert-bundle = "/etc/ssl/certs/ca-certificates.crt";

            #udp-upstream-without-downstream = "yes";
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

            # more speeed
            #serve-expired = "no";
            #serve-expired-ttl = 259200;
            #serve-expired-client-timeout = 200;

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

            local-data = [
              "\"doubleclick.net A 127.0.0.1\""
              "\"googlesyndication.com A 127.0.0.1\""
              "\"googleadservices.com A 127.0.0.1\""
              "\"google-analytics.com A 127.0.0.1\""
              "\"ads.youtube.com A 127.0.0.1\""
              "\"adserver.yahoo.com A 127.0.0.1\""
            ] ++ (lib.mapAttrsToList (name: value: "\"${name}.${net.tld}. IN A ${value.ip}\"") subdomains);

            local-data-ptr = lib.mapAttrsToList (name: value: "\"${value.ip} ${name}.${net.tld}\"") subdomains;
          };

          # downstream dns resolver
          forward-zone = [
            {
              name = ".";
              forward-tls-upstream = "yes"; # use dns over tls forwarder
              #forward-first = "no";          # don't send directly
              forward-addr = [
                "1.1.1.1@853#cloudflare-dns.com"
                "2a0e:dc0:6:23::2@853#dot-ch.blahdns.com"
                "2a01:4f8:151:34aa::198@853#dnsforge.de"
                "2001:678:e68:f000::@853#dot.ffmuc.net"
                "2a05:fc84::42@853#dns.digitale-gesellschaft.ch"

                #"1.1.1.1" # cloudflare
                #"80.241.218.68" # dismail
                #"194.242.2.2" # mullvad no adblock
                #"194.242.2.3" # mullvad ablock
                #"94.247.43.254" # open nic
              ];
            }
          ];

          #remote-control = {
          #control-enable = true;
          #};
        };
      };
  };
}
