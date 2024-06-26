{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types concatStrings;
  cfg = config.phil.server.services.nginx;
  net = config.phil.network;
in {
  options.phil.server.services.nginx = {
    proxy = mkOption {
      description = "proxy definitions";
      type = types.attrsOf types.port;
      example = {
        "jellyfin" = 1234;
      };

      default = {};
    };
  };

  config = {
    services.nginx = let
      genconfig = subdomain: port: ''
        server {
          listen 80;
          server_name ${subdomain}.${net.tld};
          location / {
            proxy_pass http://$server_addr:${toString port};
          }
        }
      '';
    in {
      enable = lib.mkDefault cfg.proxy != {};
      httpConfig = concatStrings (lib.mapAttrsToList genconfig cfg.proxy);
    };
  };
}
