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
    nginx = {
      enable = mkEnableOption "traefik reverse proxy";

      proxy = mkOption {
        description = "proxy definitions";
        type = types.attrsOf types.port;
        example = {
          "jellyfin" = 1234;
        };

        default = {};
      };
    };

    apps = mkOption {
      description = "";
      type = types.attrsOf (types.enum hostnames);
      example = {
        "jellyfin" = "beta";
      };

      default = { };
    };
  };

  config = {
    services.nginx = let
      genconfig = subdomain: port: ''
        server {
          listen 80;
          server_name ${subdomain}.home;
          location / {
            proxy_pass http://$server_addr:${toString port};
          }
        }
      '';
    in {
      enable = cfg.nginx.enable;
      httpConfig = concatStrings (lib.mapAttrsToList genconfig cfg.nginx.proxy);
    };
    phil.dns.subdomains = (builtins.mapAttrs (name: value: { ip = iplot."${value}"; }) cfg.apps);
  };
}
