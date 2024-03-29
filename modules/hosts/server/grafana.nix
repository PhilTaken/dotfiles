{
  config,
  lib,
  net,
  flake,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.grafana;

  kc-nodes = builtins.attrNames (lib.filterAttrs
    (_: v:
      lib.hasAttrByPath ["config" "phil" "server" "services" "keycloak" "enable"] v
      && v.config.phil.server.services.keycloak.enable)
    flake.nixosConfigurations);
  kc-host = flake.nixosConfigurations.${builtins.head kc-nodes}.config.phil.server.services.keycloak.host;
  kc-enabled = builtins.length kc-nodes == 1;
in {
  options.phil.server.services.grafana = {
    enable = mkEnableOption "grafana";

    host = mkOption {
      type = types.str;
      default = "grafana";
    };

    loki-port = mkOption {
      type = types.port;
      default = 3100;
    };

    prometheus-port = mkOption {
      type = types.port;
      default = 3101;
    };

    grafana-port = mkOption {
      type = types.port;
      default = 3102;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets =
      lib.genAttrs [
        "grafana-adminpass"
        "grafana-admindbpass"
        "grafana-kc-client-secret"
      ] (_: {
        owner = config.systemd.services.grafana.serviceConfig.User;
      });

    networking.firewall.interfaces."${net.networks.default.interfaceName}" = {
      allowedUDPPorts = [cfg.grafana-port cfg.loki-port cfg.prometheus-port];
      allowedTCPPorts = [cfg.grafana-port cfg.loki-port cfg.prometheus-port];
    };

    services.loki = {
      enable = true;
      configuration = {
        auth_enabled = false;
        analytics.reporting_enabled = false;

        server = {
          http_listen_port = cfg.loki-port;
          grpc_listen_port = 9060;
        };

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
          retention_period = "360h";
          max_query_series = 100000;
          max_query_parallelism = 1;
        };

        common = {
          path_prefix = "/tmp/loki";
          storage.filesystem = {
            chunks_directory = "/tmp/loki/chunks";
            rules_directory = "/tmp/loki/rules";
          };
          replication_factor = 1;
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
        };

        schema_config = {
          configs = [
            {
              from = "2020-10-24";
              store = "boltdb-shipper";
              object_store = "filesystem";
              schema = "v11";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };
        ruler.alertmanager_url = "http://localhost:9093";
      };
    };

    services.prometheus = {
      enable = true;
      port = cfg.prometheus-port;

      scrapeConfigs = let
        nodes = lib.filterAttrs (n: _v: builtins.hasAttr n net.networks.default.hosts) flake.nixosConfigurations;
        mkScrapeJob = n: v: let
          mkTargets = nodename: node: let
            ip = net.networks.default.hosts.${nodename};
            mkTargetString = port: "${ip}:${builtins.toString port}";
            exporterPorts = lib.mapAttrsToList (_: c: c.port) (lib.filterAttrs (_: c: builtins.typeOf c != "list" && c.enable) node.config.services.prometheus.exporters);
            ports =
              exporterPorts
              ++ lib.optionals node.config.phil.server.services.promexp.extrasensors [node.config.phil.server.services.promexp.prom-sensors-port];
          in
            builtins.map mkTargetString ports;
        in {
          job_name = n;
          static_configs = [
            {
              targets = mkTargets n v;
            }
          ];
        };
      in
        builtins.attrValues (lib.mapAttrs mkScrapeJob nodes);
    };

    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_port = cfg.grafana-port;
          domain = "https://${cfg.host}.${net.tld}";
          root_url = "https://${cfg.host}.${net.tld}";
          http_addr = "0.0.0.0";
          protocol = "http";
        };

        security = {
          admin_user = "admin";
          admin_password = "$__file{${config.sops.secrets.grafana-adminpass.path}}";
        };

        database = {
          user = "root";
          password = "$__file{${config.sops.secrets.grafana-admindbpass.path}}";
        };

        "auth.generic_oauth" = let
          enabled = kc-enabled;
          realm_name = "services";
          client_id = "grafana-oauth";
          client_secret = "$__file{${config.sops.secrets.grafana-kc-client-secret.path}}";
          url = "${
            if kc-enabled
            then kc-host
            else "keycloak"
          }.${net.tld}";
          oid-uri = "https://${url}/realms/${realm_name}/protocol/openid-connect";
        in {
          inherit enabled client_id client_secret;
          name = "Keycloak-OAuth";
          allow_sign_up = true;
          scopes = lib.concatStringsSep " " ["openid" "email" "profile" "offline_access" "roles"];
          email_attribute_path = "email";
          login_attribute_path = "username";
          name_attribute_path = "full_name";
          auth_url = "${oid-uri}/auth";
          token_url = "${oid-uri}/token";
          api_url = "${oid-uri}/userinfo";
          role_attribute_path = "contains(roles[*], 'grafanaadmin') && 'GrafanaAdmin' || contains(roles[*], 'admin') && 'Admin' || contains(roles[*], 'editor') && 'Editor' || 'Viewer'";
          allow_assign_grafana_admin = true;
        };
      };

      provision = {
        datasources.settings = {
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://localhost:${builtins.toString cfg.prometheus-port}";
            }
            {
              name = "Loki";
              type = "loki";
              url = "http://localhost:${builtins.toString cfg.loki-port}";
            }
          ];
        };
      };
    };

    phil.server.services = {
      caddy.proxy = {
        grafana = {
          port = cfg.grafana-port;
          public = true;
        };
        loki.port = cfg.loki-port;
        prometheus.port = cfg.prometheus-port;
      };

      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Grafana";
          subtitle = "Observability Service";
          tag = "app";
          keywords = "selfhosted data";
          logo = "https://grafana.com/static/img/about/grafana_logo_swirl_fullcolor.jpg";
        };
      };
    };
  };
}
