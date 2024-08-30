{
  config,
  lib,
  netlib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.nextcloud;
  net = config.phil.network;
in {
  options.phil.server.services.nextcloud = {
    enable = mkEnableOption "nextcloud";
    datadir = mkOption {
      type = types.str;
      default = "/media/nextcloud/";
    };

    host = mkOption {
      type = types.str;
      default = "nextcloud";
    };

    port = mkOption {
      type = types.port;
      default = netlib.portFor "nextcloud";
    };
  };

  config = let
    hostAddress = "192.0.0.1";
    localAddress = "192.0.0.2";
  in
    mkIf cfg.enable {
      sops.secrets.nextcloud-adminpass.mode = "777";

      networking.nat = {
        enable = true;
        internalInterfaces = ["ve-+"];
        externalInterface = "enp1s0";
      };

      phil.backup.jobs."nextcloud" = {
        paths = [cfg.datadir];
        # TODO postgresql backup
        # TODO turn maintenance mode on in container
        # ${config.containers.nextcloud.config.services.nextcloud.occ}/bin/nextcloud-occ maintenance:mode --on
        preHook = ''
        '';
        # TODO turn maintenance off again
        # ${config.containers.nextcloud.config.services.nextcloud.occ}/bin/nextcloud-occ maintenance:mode --off
        postHook = ''
        '';
      };

      phil.server.services = {
        caddy.proxy."${cfg.host}" = {
          inherit (cfg) port;
          ip = net.nodes.${config.networking.hostName}.network_ip.milkyway;
          public = true;
        };
        homer.apps."${cfg.host}" = {
          show = true;
          settings = {
            name = "Nextcloud";
            subtitle = "Documents and Bookmarks Cloud";
            tag = "app";
            keywords = "selfhosted cloud";
            logo = "https://nextcloud.com/wp-content/uploads/2021/12/logo.png";
          };
        };
      };

      containers.nextcloud = let
        adminpassFile = config.sops.secrets.nextcloud-adminpass.path;
        home = "/media/nextcloud";
        datadir = "/var/lib/nextcloud";
        hostName = netlib.domainFor cfg.host;
      in {
        ephemeral = false;
        autoStart = true;

        #privateNetwork = false;
        privateNetwork = true;
        inherit localAddress hostAddress;

        forwardPorts = [
          {
            containerPort = 80;
            hostPort = cfg.port;
            protocol = "tcp";
          }
        ];

        bindMounts = {
          ${adminpassFile} = {
            hostPath = adminpassFile;
            isReadOnly = true;
          };

          ${datadir} = {
            hostPath = cfg.datadir;
            isReadOnly = false;
          };

          ${home} = {
            hostPath = home;
            isReadOnly = false;
          };
        };

        config = {
          config,
          pkgs,
          ...
        }: {
          # https://github.com/NixOS/nixpkgs/issues/162686
          networking.nameservers = ["1.1.1.1"];
          # WORKAROUND
          environment.etc."resolv.conf".text = "nameserver 1.1.1.1";

          networking.firewall.enable = false;

          services.nextcloud = {
            enable = true;
            package = pkgs.nextcloud29;

            inherit home datadir hostName;
            https = false;

            extraApps = {
              inherit
                (pkgs.nextcloud29Packages.apps)
                calendar
                bookmarks
                contacts
                groupfolders
                spreed
                previewgenerator
                memories
                ;
            };

            caching.redis = true;
            caching.apcu = false;

            configureRedis = true;

            notify_push = {
              enable = false;
              bendDomainToLocalhost = true;
            };

            config = {
              adminuser = "nc-admin";
              inherit adminpassFile;
              dbtype = "pgsql";
              dbhost = "/run/postgresql";
              dbname = "nextcloud";
              dbuser = "nextcloud";
            };

            settings = {
              default_phone_region = "DE";
              overwriteprotocol = "https";
              trusted_proxies = [
                "10.200.0.1"
                "10.200.0.5"
                hostAddress
              ];
              redis = {
                host = "/run/redis-nextcloud/redis.sock";
                port = 0;
              };
              "memcache.local" = "\\OC\\Memcache\\Redis";
              "memcache.distributed" = "\\OC\\Memcache\\Redis";
              "memcache.locking" = "\\OC\\Memcache\\Redis";

              preview_max_x = 2048;
              preview_max_y = 2048;
              jpeg_quality = 60;
            };
          };

          services.redis.servers.nextcloud = {
            enable = true;
            user = "nextcloud";
            port = 0;
          };

          services.postgresql = {
            enable = true;
            package = pkgs.postgresql_14;
            ensureUsers = [
              {
                name = "nextcloud";
                ensureDBOwnership = true;
              }
            ];
            ensureDatabases = ["nextcloud"];
          };

          systemd.services."nextcloud-setup" = {
            requires = ["postgresql.service"];
            after = ["postgresql.service"];
          };

          systemd.timers."nextcloud-preview-gen" = {
            wantedBy = ["timers.target"];
            after = ["nextcloud-setup.service"];
            timerConfig = {
              OnBootSec = "10m";
              OnUnitActiveSec = "10m";
              Unit = "nextcloud-preview-gen.service";
            };
          };

          systemd.services."nextcloud-preview-gen" = {
            script = ''
              ${config.services.nextcloud.occ}/bin/nextcloud-occ preview:pre-generate
            '';

            serviceConfig = {
              Type = "oneshot";
              User = "root";
            };
          };

          system.stateVersion = "22.11";
        };
      };
    };
}
