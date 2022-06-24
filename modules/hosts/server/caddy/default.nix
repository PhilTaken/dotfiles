{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.server.services.caddy;

  net = import ../../../../network.nix { };
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
    sops.secrets.caddy_dns_cf = {
      owner = config.systemd.services.caddy.serviceConfig.User;
    };

    systemd.services.caddy.serviceConfig.AmbientCapabilities = "CAP_NET_BIND_SERVICE";

    services.caddy =
      let
        genconfig = subdomain: config:
          let
            port = if builtins.isAttrs config then config.port else config;
            ip = if builtins.isAttrs config then config.ip else "localhost";
          in
          ''
            ${subdomain}.pherzog.xyz {
              reverse_proxy http://${ip}:${toString port}
              tls {
                import ${inputs.config.sops.secrets.caddy_dns_cf.path}
              }
            }
          '';
      in
      {
        enable = true;
        package = (pkgs.callPackage ./custom_caddy.nix {
          plugins = [
            "github.com/caddy-dns/cloudflare"
          ];
          vendorSha256 = "sha256-1SBOXv2RGLlTT/mguPjTASU5AeQNIVySgVMgvu5BH6w=";
        });
        extraConfig = concatStrings (lib.mapAttrsToList genconfig cfg.proxy);
      };

    networking.firewall.interfaces."${net.networks.default.interfaceName}" = {
      allowedUDPPorts = [ 80 443 ];
      allowedTCPPorts = [ 80 443 ];
    };
  };
}
