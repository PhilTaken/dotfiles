{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.dns;
  wgpeers = import ../wireguard/wireguard-peers.nix;
  iplot = builtins.mapAttrs (name: value: builtins.elemAt (builtins.split "/" (lib.head value.ownIPs)) 0) wgpeers;

  hostnames = builtins.attrNames iplot;
  myIP = iplot.${config.networking.hostname};
in
{
  options.phil.dns = {
    traefik.enable = mkEnableOption "traefik reverse proxy";

    apps = mkOption {
      description = "";
      type = types.attrsOf (types.submodule {
        options = {
          host = mkOption {
            description = "which host the application runs on";
            type = types.enum hostnames;
            example = config.networking.hostName;
            default = (builtins.head hostnames);
          };

          port = mkOption {
            description = "application port";
            type = types.port;
            example = 8096;
          };

          setDNS = mkOption {
            description = "wether to also set the dns rebind for the current host";
            type = types.bool;
            default = true;
          };
        };
      });

      example = {
        "jellyfin" = {
          host = "beta";
          port = 8096;
        };
      };

      default = {
        "jellyfin" = {
          host = "beta";
          port = 8096;
        };
      };
    };
  };

  config = mkIf (cfg.traefik.enable) {
    services.traefik = {
      enable = true;
    };

    phil.dns.subdomains = (builtins.mapAttrs (name: value: { ip = iplot."${value.host}"; }) cfg.apps);
  };
}
