# TODO: move storage to s3 compatible storage -> host-independent?
{
  config,
  lib,
  flake,
  netlib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.grafana;
  net = config.phil.network;

  proxy_network = "headscale";

  kc-nodes = builtins.attrNames (lib.filterAttrs (_: v: builtins.elem "keycloak" v.services) net.nodes);
  kc-host = flake.nixosConfigurations.${builtins.head kc-nodes}.config.phil.server.services.keycloak.host;

  # TODO what do when multiple keycloaks defined?
  kc-enabled = builtins.length kc-nodes == 1;

  # TODO improve this with shiver?
  scrapeConfigs = let
    mkScrapeJob = n: v: let
      mkTargets = nodename: node: let
        ip = net.nodes.${nodename}.network_ip.${proxy_network};
        mkTargetString = port: "${ip}:${builtins.toString port}";
        has_extrasensors = flake.nixosConfigurations.${nodename}.config.phil.server.services.promexp.extrasensors;

        # in sync with prometheus/prometheus-exporter.nix
        exporters = builtins.removeAttrs flake.nixosConfigurations.${nodename}.config.services.prometheus.exporters ["assertions" "warnings" "minio" "tor"];
        enabled_exporters = lib.filterAttrs (_: v: v.enable) exporters;
        exporter_ports = lib.mapAttrsToList (_: v: v.port) enabled_exporters;

        ports = exporter_ports ++ lib.optional has_extrasensors flake.nixosConfigurations.${nodename}.config.phil.server.services.promexp.prom-sensors-port;
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
    builtins.attrValues (lib.mapAttrs mkScrapeJob net.nodes);

  grafana-domain = "https://${netlib.domainFor cfg.host}";

  oid-uri = let
    realm_name = "services";
    url = netlib.domainFor (
      if kc-enabled
      then kc-host
      else "keycloak"
    );
  in "https://${url}/realms/${realm_name}/protocol/openid-connect";
in {
  options.phil.server.services.grafana = {
    enable = mkEnableOption "grafana";

    host = mkOption {
      type = types.str;
      default = "grafana";
    };

    loki-grpc-port = mkOption {
      type = types.port;
      default = netlib.portFor "loki-grpc";
    };

    loki-port = mkOption {
      type = types.port;
      default = netlib.portFor "loki";
    };

    prometheus-port = mkOption {
      type = types.port;
      default = netlib.portFor "prometheus";
    };

    grafana-port = mkOption {
      type = types.port;
      default = netlib.portFor "grafana";
    };

    tempo-port = mkOption {
      type = types.port;
      default = netlib.portFor "tempo";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.hasAttr "public_ip" net.nodes.${config.networking.hostName};
        message = "the grafana node needs a public ip for loki function properly (grpc)";
      }
    ];

    sops.secrets =
      lib.genAttrs [
        "grafana-adminpass"
        "grafana-admindbpass"
        "grafana-kc-client-secret"
      ] (_: {
        owner = config.systemd.services.grafana.serviceConfig.User;
      });

    services.loki = {
      enable = true;
      configuration = {
        auth_enabled = false;
        analytics.reporting_enabled = false;

        server = {
          http_listen_address = "0.0.0.0";
          http_listen_port = cfg.loki-port;
          grpc_listen_address = "0.0.0.0";
          grpc_listen_port = cfg.loki-grpc-port;
        };

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
          retention_period = "1440h";
          max_query_series = 100000;
          max_query_parallelism = 1;
        };

        common = {
          path_prefix = "/var/lib/loki";
          storage.filesystem = {
            chunks_directory = "/var/lib/loki/chunks";
            rules_directory = "/varr/lib/loki/rules";
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
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
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
      globalConfig.scrape_interval = "15s";
      inherit scrapeConfigs;
    };

    services.tempo = {
      enable = true;
      settings = {
        server = {
          http_listen_address = "0.0.0.0";
          http_listen_port = cfg.tempo-port;
          graceful_shutdown_timeout = "10s";
        };
        distributor.receivers = {
          otlp.protocols = {
            http = {};
          };
        };
        storage.trace = {
          backend = "local";
          wal.path = "/var/lib/tempo/wal";
          local.path = "/var/lib/tempo/blocks";
        };
        usage_report.reporting_enabled = false;
      };
    };
    services.opentelemetry-collector.enable = lib.mkForce false;

    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_port = cfg.grafana-port;
          domain = grafana-domain;
          root_url = grafana-domain;
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
          client_secret = "$__file{${config.sops.secrets.grafana-kc-client-secret.path}}";
          client_id = "grafana-oauth";
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
        enable = true;
        dashboards = {
          settings = {
            providers = [
              {
                name = "dashboards";
                options.path = ./resources/dashboards/general;

                # allow editing in the ui, just make sure to sync the update with this repo using grr
                allowUiUpdates = true;
              }
            ];
          };
        };

        datasources.settings = {
          datasources = [
            {
              name = "Tempo";
              type = "tempo";
              url = "http://localhost:${builtins.toString cfg.tempo-port}";
              uid = "P214B5B846CF3925F";
            }
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://localhost:${builtins.toString cfg.prometheus-port}";
              jsonData.timeInterval = config.services.prometheus.globalConfig.scrape_interval;
              uid = "PBFA97CFB590B2093";
            }
            {
              name = "Loki";
              type = "loki";
              url = "http://localhost:${builtins.toString cfg.loki-port}";
              uid = "P8E80F9AEF21F6940";
            }
          ];
        };
      };
    };

    networking.firewall = {
      allowedUDPPorts = [cfg.loki-grpc-port];
      allowedTCPPorts = [cfg.loki-grpc-port];
    };

    phil.server.services = {
      caddy.proxy = {
        grafana = {
          port = cfg.grafana-port;
          public = true;
        };
        loki.port = cfg.loki-port;
        prometheus.port = cfg.prometheus-port;
        tempo.port = cfg.tempo-port;
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
