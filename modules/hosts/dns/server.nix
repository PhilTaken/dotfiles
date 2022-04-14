{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.dns;
in
{
  options.phil.dns = {
    unbound.enable = mkEnableOption "enable the unbound server";
    subdomains = mkOption {
      description = "";
      type = types.attrsOf (types.submodule {
        options = {
          ip = mkOption {
            description = "";
            type = types.str;
            example = "192.168.192.1";
          };
        };
      });

      example = {
        "alpha".ip = "192.168.192.1";
      };

      default = {};
      #default = {
        #"home".ip = "10.100.0.2";
        #"jellyfin".ip = "10.100.0.2";
        #"syncthing".ip = "10.100.0.2";
        #"notes".ip = "10.100.0.2";
        #"influx".ip = "10.100.0.1";
      #};
    };
  };

  # TODO: enable condition
  config = mkIf (cfg.unbound.enable) {
    services.unbound = {
      enable = true;
      # WIP: generate settings from options
      # see https://dnswatch.com/dns-docs/UNBOUND/
      settings = {
        server = {
          interface = [ "0.0.0.0" "::0" ];
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

          private-domain = "home.lan";
          val-clean-additional = "yes";
        };

        local-zone = [
          "\"doubleclick.net\" redirect"
          "\"googlesyndication.com\" redirect"
          "\"googleadservices.com\" redirect"
          "\"google-analytics.com\" redirect"
          "\"ads.youtube.com\" redirect"
          "\"adserver.yahoo.com\" redirect"

          "\"home.\" static"
        ];

        local-data = [
          "doubleclick.net A 127.0.0.1"
          "googlesyndication.com A 127.0.0.1"
          "googleadservices.com A 127.0.0.1"
          "google-analytics.com A 127.0.0.1"
          "ads.youtube.com A 127.0.0.1"
          "adserver.yahoo.com A 127.0.0.1"
        ] ++ (lib.mapAttrsToList (name: value: "${name}.home. IN AA ${value.ip}") cfg.subdomains);

        local-data-ptr = lib.mapAttrsToList (name: value: "${value.ip} ${name}.home") cfg.subdomains;

        forward-zone = [
          {
            name = ".";
            forward-addr = [
              "94.247.43.254"
              "1.1.1.1"
            ];
          }
        ];
        remote-control.control-enable = true;
      };

      # interfaces = {};
    };
  };
}
