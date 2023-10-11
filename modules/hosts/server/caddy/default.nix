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

  allHostProxies =
    lib.mapAttrs
    (_n: v: v.config.phil.server.services.caddy.proxy)
    (lib.filterAttrs
      (n: v: lib.hasAttrByPath ["config" "phil" "server" "services" "caddy" "proxy"] v)
      flake.nixosConfigurations);

  endpoints = builtins.attrNames net.endpoints;
  isEndpoint = n: (builtins.elem n endpoints);
  hiddenHostProxies = lib.filterAttrs (n: _: !(isEndpoint n)) allHostProxies;

  domains = let
    rdomains =
      lib.optionals
      true #(isEndpoint config.networking.hostName)
      
      (builtins.concatMap (x: x) (map builtins.attrNames (builtins.attrValues allHostProxies)));
  in
    map (domain: "${domain}.${net.tld}") rdomains;
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
    sops.secrets.acme_dns_cf = {
      owner = config.systemd.services.caddy.serviceConfig.User;
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "philipp.herzog@protonmail.com";
      defaults.group = config.services.caddy.group;
      defaults.dnsResolver = "1.1.1.1:53";
      certs = lib.genAttrs domains (domain: {
        dnsProvider = "cloudflare";
        credentialsFile = config.sops.secrets.acme_dns_cf.path;
      });
    };

    systemd.services.caddy.serviceConfig.AmbientCapabilities = "CAP_NET_BIND_SERVICE";
    systemd.services.caddy.after = map (d: "acme-finished-${d}.target") domains;
    systemd.services.caddy.wants = map (d: "acme-finished-${d}.target") domains;

    services.caddy = let
      genconfig = subdomain: {
        proxycfg,
        public,
        ...
      }: let
        dir = config.security.acme.certs."${subdomain}.${net.tld}".directory;
        certfile = "${dir}/cert.pem";
        keyfile = "${dir}/key.pem";
      in ''
        ${subdomain}.${net.tld} {
          ${lib.optionalString (!public) ''
          @denied not remote_ip private_ranges
          abort @denied
        ''}
          ${proxycfg}
          tls ${certfile} ${keyfile}
        }
      '';
    in {
      enable = true;
      globalConfig = ''
        admin 0.0.0.0:${builtins.toString cfg.adminport}
        servers {
          metrics
        }
      '';

      extraConfig = let
        updateConfigWithHost = host: _proxy: config:
          lib.recursiveUpdate config {
            proxycfg = ''
              reverse_proxy ${net.networks.yggdrasil.hosts.${host}}:${builtins.toString config.port} {
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
            # add reverse proxy entries for all services on other non-endpoint (hidden) systems
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
