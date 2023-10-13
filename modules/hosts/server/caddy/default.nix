{
  pkgs,
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

      proxyPass = mkOption {
        type = types.nullOr types.str;
        default =
          if config.root == null
          then "http://${config.ip}:${toString config.port}"
          else null;
      };

      root = mkOption {
        type = types.nullOr types.str;
        default = null;
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
    (map (domain: "${domain}.${net.tld}") rdomains) ++ ["pherzog.xyz" "www.pherzog.xyz"];
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
      recommendedProxySettings = true;
      virtualHosts = let
        inherit (config.security.acme) certs;
        genconfig = subdomain: {public, ...} @ proxycfg: let
          fqdn = "${subdomain}.${net.tld}";
        in {
          name = fqdn;
          value = {
            forceSSL = true;
            enableACME = true;
            sslCertificate = "${certs.${fqdn}.directory}/fullchain.pem";
            sslCertificateKey = "${certs.${fqdn}.directory}/key.pem";
            sslTrustedCertificate = "${certs.${fqdn}.directory}/chain.pem";
            locations."/" = {
              inherit (proxycfg) root proxyPass;
              extraConfig = ''
                proxy_redirect http:// https://;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection $connection_upgrade;
              '';
            };
            extraConfig = lib.optionalString (!public) ''
              ${builtins.concatStringsSep "\n" (map (n: "allow ${n};") (builtins.catAttrs "netmask" (builtins.attrValues net.networks)))}
              deny all;
            '';
          };
        };
        updateConfigWithHost = host: _proxy: config:
          lib.recursiveUpdate config {
            proxyPass = "http://${net.networks.yggdrasil.hosts.${host}}:${builtins.toString config.port}";
          };

        updatedProxies = lib.mapAttrs (host: proxies: lib.mapAttrs (updateConfigWithHost host) proxies) hiddenHostProxies;

        myProxies = let
          host = config.networking.hostName;
        in
          if isEndpoint host
          then lib.foldl' lib.recursiveUpdate allHostProxies.${host} (lib.attrValues updatedProxies)
          else allHostProxies.${host};
      in
        (lib.mapAttrs' genconfig myProxies)
        // {
          "www.${net.tld}" = let
            fqdn = "www.${net.tld}";
          in {
            forceSSL = true;
            enableACME = true;
            sslCertificate = "${certs.${fqdn}.directory}/fullchain.pem";
            sslCertificateKey = "${certs.${fqdn}.directory}/key.pem";
            sslTrustedCertificate = "${certs.${fqdn}.directory}/chain.pem";
            globalRedirect = "pherzog.xyz";
          };

          ${net.tld} = {
            forceSSL = true;
            enableACME = true;
            sslCertificate = "${certs.${net.tld}.directory}/fullchain.pem";
            sslCertificateKey = "${certs.${net.tld}.directory}/key.pem";
            sslTrustedCertificate = "${certs.${net.tld}.directory}/chain.pem";
            globalRedirect = "gitea.pherzog.xyz";
          };

          "external_ip" = lib.mkIf (builtins.hasAttr config.networking.hostName net.endpoints) {
            serverName = net.endpoints.${config.networking.hostName};
            globalRedirect = "pherzog.xyz";
          };
        };

      additionalModules = [pkgs.nginxModules.geoip2];
      appendHttpConfig = ''
        map $http_referer $httpReferer {
          default "$http_referer";
          ""      "(direct)";
        }

        map $http_user_agent $httpAgent {
          default "$http_user_agent";
          ""      "Unknown";
        }

        map $geoip2_country_code $geoIP {
          default "$geoip2_country_code";
          ""      "Unknown";
        }

        geoip2 ${config.services.geoipupdate.settings.DatabaseDirectory}/GeoLite2-Country.mmdb {
          $geoip2_country_code country iso_code;
        }

        # https://grafana.com/grafana/dashboards/12559-loki-nginx-service-mesh-json-version/
        log_format json_analytics escape=json '{'
          '"args": "$args", ' # args
          '"body_bytes_sent": "$body_bytes_sent", ' # the number of body bytes exclude headers sent to a client
          '"bytes_sent": "$bytes_sent", ' # the number of bytes sent to a client
          '"connection": "$connection", ' # connection serial number
          '"connection_requests": "$connection_requests", ' # number of requests made in connection
          '"geoip_country_code": "$geoIP", '
          '"gzip_ratio": "$gzip_ratio", '
          '"http_cf_ray": "$http_cf_ray",'
          '"http_host": "$http_host", ' # the request Host: header
          '"http_referer": "$httpReferer", ' # HTTP referer
          '"http_user_agent": "$httpAgent", ' # user agent
          '"http_x_forwarded_for": "$http_x_forwarded_for", ' # http_x_forwarded_for
          '"msec": "$msec", ' # request unixtime in seconds with a milliseconds resolution
          '"pid": "$pid", ' # process pid
          '"pipe": "$pipe", ' # "p" if request was pipelined, "." otherwise
          '"remote_addr": "$remote_addr", ' # client IP
          '"remote_port": "$remote_port", ' # client port
          '"remote_user": "$remote_user", ' # client HTTP username
          '"request": "$request", ' # full path no arguments if the request
          '"request_id": "$request_id", ' # the unique request id
          '"request_length": "$request_length", ' # request length (including headers and body)
          '"request_method": "$request_method", ' # request method
          '"request_time": "$request_time", ' # request processing time in seconds with msec resolution
          '"request_uri": "$request_uri", ' # full path and arguments of the request
          '"scheme": "$scheme", ' # http or https
          '"server_name": "$server_name", ' # the name of the vhost serving the request
          '"server_protocol": "$server_protocol", ' # request protocol, like HTTP/1.1 or HTTP/2.0
          '"ssl_cipher": "$ssl_cipher", ' # TLS cipher
          '"ssl_protocol": "$ssl_protocol", ' # TLS protocol
          '"status": "$status", ' # response status code
          '"time_iso8601": "$time_iso8601", ' # local time in the ISO 8601 standard format
          '"time_local": "$time_local", '
          '"upstream": "$upstream_addr", ' # upstream backend server for proxied requests
          '"upstream_cache_status": "$upstream_cache_status", ' # cache HIT/MISS where applicable
          '"upstream_connect_time": "$upstream_connect_time", ' # upstream handshake time incl. TLS
          '"upstream_header_time": "$upstream_header_time", ' # time spent receiving upstream headers
          '"upstream_response_length": "$upstream_response_length", ' # upstream response length
          '"upstream_response_time": "$upstream_response_time"' # time spend receiving upstream body
        '}';

        access_log /var/log/nginx/analytics.log json_analytics;
      '';
    };

    sops.secrets.geoip-licensekey = {};

    services.geoipupdate = {
      enable = true;
      settings = {
        AccountID = 924802;
        DatabaseDirectory = "/var/lib/GeoIP";
        LicenseKey = config.sops.secrets.geoip-licensekey.path;
        EditionIDs = ["GeoLite2-Country"];
      };
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
