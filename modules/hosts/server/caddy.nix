{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.caddy;

  net = import ../../../network.nix { };
  iplot = net.networks.default;
  hostnames = builtins.attrNames iplot;
  ipOpts = { ... }: {
    options = {
      ip = mkOption {
        type = types.str;
      };

      port = mkOption {
        type = types.port;
      };
    };
  };
in
{
  options.phil.server.services.caddy = {
    proxy = mkOption {
      description = "proxy definitions";
      type = types.attrsOf (types.either (types.submodule ipOpts) types.port);
      example = {
        "jellyfin" = 1234;
      };

      default = { };
    };
  };

  config = mkIf (cfg.proxy != { }) {
    services.caddy =
      let
        genconfig = subdomain: config:
          let
            port = if builtins.isAttrs config then config.port else config;
            ip = if builtins.isAttrs config then config.ip else "localhost";
          in
          ''
            ${subdomain}.pherzog.xyz {
              tls internal
              reverse_proxy http://${ip}:${toString port}
            }
            ${subdomain}.home {
              tls internal
              reverse_proxy http://${ip}:${toString port}
            }
          '';
      in
      {
        enable = true;
        extraConfig = concatStrings (lib.mapAttrsToList genconfig cfg.proxy);
      };

    networking.firewall.interfaces."${net.networks.default.interfaceName}" = {
      allowedUDPPorts = [ 80 443 ];
      allowedTCPPorts = [ 80 443 ];
    };
  };
}
