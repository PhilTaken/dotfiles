{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.dns;
  wgpeers = import ../wireguard/wireguard-peers.nix;
  iplot = lib.mapAttrsToList (name: value: { ${name} = builtins.elemAt (builtins.split "/" (lib.head value.ownIPs)) 0; }) wgpeers;
  hostnames = attrNames iplot;
  myIP = iplot.${config.networking.hostname};
in
{
  options.phil.dns = {
    traefik.enable = mkEnableOption "traefik reverse proxy";

    apps = mkOption {
      description = "";
      type = types.attrsOf (types.submodule {
        port = mkOption {
          description = "application port";
          type = types.port;
          example = 8086;
        };

        openFirewall = mkOption {
          description = "wether to open the port in the firewall";
          type = types.bool;
          default = true;
        };

        host = mkOption {
          description = "which host the application runs on";
          type = types.enum hostnames;
          example = config.networking.hostName;
        };

        interface = mkOption {
          description = "interface to run the application on";
          type = types.str;
          default = "yggdrasil";
        };

        setDNS = mkOption {
          description = "wether to also set the dns rebind for the current host";
          type = types.bool;
          default = true;
        };
      });

      example = {
        "jellyfin" = {
          host = "beta";
          port = 8086;
        };
      };

      default = {
        "jellyfin" = {
          host = "beta";
          port = 8086;
        };
      };
    };
  };

  config = mkIf (cfg.traefik.enable) {
    services.traefik = {
      enable = true;
    };

    phil.dns.subdomains = mkIf (cfg.setDNS)
      (lib.listToAttrs
        (map
          (val: { name = val; value = { ip = myIP; }; })
          (lib.attrNames cfg.apps)));
  };
}
