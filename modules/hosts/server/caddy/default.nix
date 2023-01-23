{ pkgs
, config
, inputs
, lib
, ...
}@inattrs:
let
  cfg = config.phil.server.services.caddy;
  net = import ../../../../network.nix { };

  inherit (lib) mkOption types mkIf concatStrings;

  ipOptsType = types.submodule ({ config, ... }: {
    options = {
      ip = mkOption {
        type = types.str;
        default = "";
      };

      port = mkOption {
        type = types.nullOr types.port;
        default = null;
      };

      proxycfg = mkOption {
        type = types.str;
        default = "reverse_proxy http://${config.ip}:${toString config.port}";
      };
    };
  });
in
{
  options.phil.server.services.caddy = {
    # TODO: autogenerate from host/port in services
    proxy = mkOption {
      description = "proxy definitions";
      type = types.attrsOf ipOptsType;
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
        genconfig = subdomain: {port, ip, proxycfg}: ''
          ${subdomain}.${net.tld} {
            ${proxycfg}
            tls {
              import ${inattrs.config.sops.secrets.caddy_dns_cf.path}

              resolvers 1.1.1.1
            }
          }
        '';
      in
      {
        enable = true;
        package = pkgs.callPackage ./custom_caddy.nix {
          plugins = [{
            name = "github.com/caddy-dns/cloudflare";
            version = "91cf700356a1cd0127bcc4e784dd50ed85794af5";
          }];

          vendorSha256 = "sha256-2GsdT76Kvey69mLuUlePzHb6TLlTPZepOtcUlVuphxc=";
        };
        extraConfig = (concatStrings (lib.mapAttrsToList genconfig cfg.proxy));
      };

    networking.firewall.interfaces."${net.networks.default.interfaceName}" = {
      allowedUDPPorts = [ 80 443 ];
      allowedTCPPorts = [ 80 443 ];
    };
  };
}
