{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.nginx;

  net = import ../../../network.nix { };
  iplot = net.networks.default;
  hostnames = builtins.attrNames iplot;
in
{
  options.phil.server.services.nginx = {
    proxy = mkOption {
      description = "proxy definitions";
      type = types.attrsOf types.port;
      example = {
        "jellyfin" = 1234;
      };

      default = { };
    };
  };

  config = {
    services.nginx =
      let
        genconfig = subdomain: port: ''
          server {
            listen 80;
            server_name ${subdomain}.pherzog.xyz;
            location / {
              proxy_pass http://$server_addr:${toString port};
            }
          }
        '';
      in
      {
        enable = cfg.proxy != { };
        httpConfig = concatStrings (lib.mapAttrsToList genconfig cfg.proxy);
      };
  };
}
