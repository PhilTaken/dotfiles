{ pkgs
, config
, lib
, ...
}:
with lib;

# TODO: remove unbound dns entry

let
  contains = val: builtins.foldl' (accum: elem: elem == val || accum) false;

  cfg = config.phil.server.services.unbound;
  net = import ../../../network.nix { };
  iplot = net.networks.default;
  hostnames = builtins.attrNames iplot;
  mkDnsBindsFromServices = services: builtins.mapAttrs
    # TODO: sensible handling for identical services on multiple hosts
    (_: hosts: builtins.head hosts)
    (lib.zipAttrs
      (builtins.map
        (host: builtins.listToAttrs (builtins.map
          (service:
            let
              name = config.phil.server.services.${service}.host or service;
              value = host;
            in
            { inherit name value; })
          (builtins.filter (lib.flip contains [ "unbound" "caddy" ]) services.${host})))
        (builtins.attrNames services)));

  adblockLocalZones = pkgs.stdenv.mkDerivation {
    name = "unbound-zones-adblock";

    src = (pkgs.fetchFromGitHub
      {
        owner = "StevenBlack";
        repo = "hosts";
        rev = "3.0.0";
        sha256 = "01g6pc9s1ah2w1cbf6bvi424762hkbpbgja9585a0w99cq0n6bxv";
      } + "/hosts");

    phases = [ "installPhase" ];

    installPhase = ''
      ${pkgs.gawk}/bin/awk '{sub(/\r$/,"")} {sub(/^127\.0\.0\.1/,"0.0.0.0")} BEGIN { OFS = "" } NF == 2 && $1 == "0.0.0.0" { print "local-zone: \"", $2, "\" static"}' $src | tr '[:upper:]' '[:lower:]' | sort -u >  $out
    '';
  };
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
      default = mkDnsBindsFromServices net.services;
    };
  };

  # TODO: enable condition
  config = mkIf (cfg.enable) {
    networking.firewall.interfaces."${net.networks.default.interfaceName}" = {
      allowedUDPPorts = [ 53 ];
      allowedTCPPorts = [ 53 ];
    };
    services.unbound =
      let
        subdomains = (builtins.mapAttrs (name: value: { ip = iplot."${value}"; }) cfg.apps);
      in
      {
        enable = true;
        settings = {
          server = {
            access-control = [
              "127.0.0.0/8 allow" # localhost
              "10.100.0.1/24 allow" # yggdrasil
              "10.200.0.1/24 allow" # milkyway
              "192.168.0.1/24 allow" # local net
            ];
            interfaces = [ "0.0.0.0" "::0" ];

            #tls-cert-bundle: /etc/ssl/certs/ca-certificates.crt
            #tls-upstream: yes
            extraConfig = ''
              so-reuseport: yes
              include: "${adblockLocalZones}"
            '';

            qname-minimisation = "yes";
            serve-expired-client-timeout = 1800;
            do-ip4 = "yes";
            do-ip6 = "no";
            do-udp = "yes";
            do-tcp = "yes";
            hide-identity = "yes";
            hide-version = "yes";
            harden-glue = "yes";
            harden-dnssec-stripped = "yes";
            use-caps-for-id = "no";
            cache-min-ttl = 3600;
            cache-max-ttl = 86400;
            prefetch = "yes";

            # performance
            rrset-cache-size = "256m";
            msg-cache-size = "128m";
            so-rcvbuf = "8m";

            val-clean-additional = "yes";

            local-zone = [
              "\"doubleclick.net\" redirect"
              "\"googlesyndication.com\" redirect"
              "\"googleadservices.com\" redirect"
              "\"google-analytics.com\" redirect"
              "\"ads.youtube.com\" redirect"
              "\"adserver.yahoo.com\" redirect"

              "\"home.\" static"
              "\"pherzog.xyz.\" static"
            ];

            local-data = [
              "\"doubleclick.net A 127.0.0.1\""
              "\"googlesyndication.com A 127.0.0.1\""
              "\"googleadservices.com A 127.0.0.1\""
              "\"google-analytics.com A 127.0.0.1\""
              "\"ads.youtube.com A 127.0.0.1\""
              "\"adserver.yahoo.com A 127.0.0.1\""
            ] ++
            (lib.mapAttrsToList (name: value: "\"${name}.home. IN A ${value.ip}\"") subdomains) ++
            (lib.mapAttrsToList (name: value: "\"${name}.pherzog.xyz. IN A ${value.ip}\"") subdomains);

            local-data-ptr =
              (lib.mapAttrsToList (name: value: "\"${value.ip} ${name}.home\"") subdomains) ++
              (lib.mapAttrsToList (name: value: "\"${value.ip} ${name}.pherzog.xyz\"") subdomains);
          };

          forward-zone = [
            {
              name = ".";
              forward-addr = [
                "94.247.43.254"
                "1.1.1.1"
              ];
            }
          ];

          remote-control = {
            control-enable = true;
          };
        };
      };
  };
}
