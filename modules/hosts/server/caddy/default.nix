{
  config,
  lib,
  net,
  flake,
  ...
}: let
  cfg = config.phil.server.services.caddy;

  inherit (lib) mkOption types mkIf;

  ipOptsType = types.submodule ({config, ...}: {
    options = {
      ip = mkOption {
        type = types.str;
        default = "127.0.0.1";
      };

      port = mkOption {
        type = types.port;
        default = 80;
      };

      proxycfg = mkOption {
        type = types.str;
        default = "proxy_pass http://${config.ip}:${toString config.port};";
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
    rdomains = builtins.concatMap builtins.attrNames (builtins.attrValues allHostProxies);
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
      #owner = config.systemd.services.caddy.serviceConfig.User;
      owner = config.systemd.services.nginx.serviceConfig.User;
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = "philipp.herzog@protonmail.com";
      defaults.group = config.services.nginx.group;
      defaults.dnsResolver = "1.1.1.1:53";
      defaults.webroot = null;
      certs = lib.genAttrs domains (domain: {
        dnsProvider = "cloudflare";
        credentialsFile = config.sops.secrets.acme_dns_cf.path;
        webroot = lib.mkForce null;
      });
    };

    #systemd.services.caddy.serviceConfig.AmbientCapabilities = "CAP_NET_BIND_SERVICE";

    services.nginx = {
      enable = true;
      virtualHosts = let
        inherit (config.security.acme) certs;
        genconfig = subdomain: {
          proxycfg,
          public,
          ...
        }: let
          fqdn = "${subdomain}.${net.tld}";
        in {
          name = fqdn;
          value = {
            forceSSL = true;
            enableACME = true;
            sslCertificate = "${certs.${fqdn}.directory}/fullchain.pem";
            sslCertificateKey = "${certs.${fqdn}.directory}/key.pem";
            sslTrustedCertificate = "${certs.${fqdn}.directory}/chain.pem";
            extraConfig =
              lib.optionalString (!public) ''
                ${builtins.concatStringsSep "\n" (map (n: "allow ${n};") (builtins.catAttrs "netmask" (builtins.attrValues net.networks)))}
                deny all;
              ''
              + ''
                location / {
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header Upgrade $http_upgrade;
                  proxy_set_header Connection "upgrade";
                  proxy_http_version 1.1;

                  ${proxycfg}
                }
              '';
          };
        };
        updateConfigWithHost = host: _proxy: config:
          lib.recursiveUpdate config {
            proxycfg = ''
              proxy_pass http://${net.networks.yggdrasil.hosts.${host}}:${builtins.toString config.port};
            '';
          };

        updatedProxies = lib.mapAttrs (host: proxies: lib.mapAttrs (updateConfigWithHost host) proxies) hiddenHostProxies;

        myProxies = let
          host = config.networking.hostName;
        in
          if isEndpoint host
          then lib.foldl' lib.recursiveUpdate allHostProxies.${host} (lib.attrValues updatedProxies)
          else allHostProxies.${host};
      in
        lib.mapAttrs' genconfig myProxies;
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
