{
  pkgs,
  config,
  lib,
  net,
  flake,
  ...
} @ inattrs: let
  cfg = config.phil.server.services.caddy;

  inherit (lib) mkOption types mkIf concatStrings;

  ipOptsType = types.submodule ({config, ...}: {
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

      publicProxyConfig = mkOption {
        type = types.lines;
        default = "";
      };

      public = mkOption {
        type = types.bool;
        default = false;
        description = "allow public access to this proxy";
      };
    };
  });
in {
  options.phil.server.services.caddy = {
    # TODO: autogenerate from host/port in services
    proxy = mkOption {
      description = "proxy definitions";
      type = types.attrsOf ipOptsType;
      default = {};
    };

    adminport = mkOption {
      description = "admin port for caddy";
      type = types.port;
      default = 2019;
    };
  };

  config = mkIf (cfg.proxy != {}) {
    sops.secrets.caddy_dns_cf = {
      owner = config.systemd.services.caddy.serviceConfig.User;
    };

    systemd.services.caddy.serviceConfig.AmbientCapabilities = "CAP_NET_BIND_SERVICE";

    services.caddy = let
      genconfig = subdomain: {
        proxycfg,
        public,
        ...
      }: ''
        ${subdomain}.${net.tld} {
          ${lib.optionalString (!public) ''
          @denied not remote_ip private_ranges
          abort @denied
        ''}
          ${proxycfg}
          tls {
            import ${inattrs.config.sops.secrets.caddy_dns_cf.path}

            resolvers 1.1.1.1
          }
        }
      '';
    in {
      enable = true;
      package = pkgs.callPackage ./custom_caddy.nix {
        plugins = [
          {
            name = "github.com/caddy-dns/cloudflare";
            version = "91cf700356a1cd0127bcc4e784dd50ed85794af5";
          }
        ];

        vendorHash = "sha256-dN53GyT5gZTrobkuwtd0Tr0ZSR/jS1kAy26Hmk04y08=";
      };

      globalConfig = ''
        admin 0.0.0.0:${builtins.toString cfg.adminport}
        servers {
          metrics
        }
      '';

      extraConfig = let
        isEndpoint = n: (builtins.elem n (builtins.attrNames net.networks.endpoints));
        hiddenHosts = builtins.attrNames (lib.filterAttrs (n: _: ! builtins.elem n (builtins.attrNames net.networks.endpoints)) flake.nixosConfigurations);
        hiddenHostProxies = let
          hosts =
            lib.filterAttrs
            (n: v: builtins.elem n hiddenHosts && lib.hasAttrByPath ["config" "phil" "server" "services" "caddy" "proxy"] v)
            flake.nixosConfigurations;
        in
          lib.mapAttrs (_n: v: v.config.phil.server.services.caddy.proxy) hosts;

        updateConfigWithHost = host: _proxy: config:
          lib.recursiveUpdate config {
            proxycfg = ''
              reverse_proxy ${net.networks.yggdrasil.${host}}:${builtins.toString config.port} {
                ${config.publicProxyConfig}
              }
            '';
          };

        updatedProxies = lib.mapAttrs (host: proxies: lib.mapAttrs (updateConfigWithHost host) proxies) hiddenHostProxies;
        otherProxies = lib.foldl' lib.recursiveUpdate {} (lib.attrValues updatedProxies);
      in
        concatStrings
        (lib.mapAttrsToList genconfig
          (lib.recursiveUpdate
            cfg.proxy
            (lib.optionalAttrs
              (isEndpoint config.networking.hostName)
              otherProxies)));
    };

    networking.firewall = {
      allowedUDPPorts = [80 443];
      allowedTCPPorts = [80 443];
    };

    networking.firewall.interfaces.${net.networks.default.interfaceName} = {
      allowedTCPPorts = [2019];
      allowedUDPPorts = [2019];
    };
  };
}
