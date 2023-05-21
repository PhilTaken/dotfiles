{
  config,
  lib,
  net,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.nextcloud;
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
  };

  config = let
    port = 80;
    hostAddress = "192.0.0.1";
    localAddress = "192.0.0.2";
  in
    mkIf cfg.enable {
      sops.secrets.nextcloud-adminpass = {
        mode = "777";
      };

      networking.nat = {
        enable = true;
        internalInterfaces = ["ve-+"];
        externalInterface = "enp1s0";
      };

      phil.backup.jobs."nextcloud" = {
        paths = [cfg.datadir];
        # TODO postgresql backup
        preHook = ''
          ${config.containers.nextcloud.config.services.nextcloud.occ}/bin/nextcloud-occ maintenance:mode --on
        '';
        postHook = ''
          ${config.containers.nextcloud.config.services.nextcloud.occ}/bin/nextcloud-occ maintenance:mode --off
        '';
      };

      phil.server.services = {
        caddy.proxy."${cfg.host}" = {
          inherit port;
          ip = localAddress;
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
      in
        mkIf cfg.enable {
          ephemeral = false;
          autoStart = true;

          privateNetwork = true;
          inherit localAddress hostAddress;

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

            environment.systemPackages = [
              (pkgs.writeShellScriptBin "fix-pics" ''
                #!/bin/sh

                albumdir=$1

                echo "Changing modified date to shot date..."
                ${pkgs.exiftool}/bin/exiftool "-filemodifydate<datetimeoriginal" -r "$albumdir"

                echo "Renaming files to shot date..."
                ${pkgs.exiftool}/bin/exiftool '-FileName<DateTimeOriginal' -r -d "%Y-%m-%d_%H.%M.%S%%-c.%%e" "$albumdir"

                # uncomment the below command if running on the server
                echo "Re-scanning your Nextcloud data directory..."
                ${config.services.nextcloud.occ}/bin/nextcloud-occ files:scan --all

                exit 0
              '')
            ];

            services.nextcloud = {
              enable = true;
              package = pkgs.nextcloud26;

              inherit home datadir;
              hostName = "${cfg.host}.${net.tld}";
              https = true;

              extraApps = {
                inherit
                  (pkgs.nextcloud26Packages.apps)
                  calendar
                  news
                  bookmarks
                  contacts
                  deck
                  groupfolders
                  impersonate
                  spreed
                  unsplash
                  twofactor_webauthn
                  previewgenerator
                  ;
                # "onlyoffice" "tasks"
              };

              caching.redis = true;
              caching.apcu = false;

              config = {
                adminuser = "admin";
                inherit adminpassFile;
                dbtype = "pgsql";
                dbhost = "/run/postgresql";
                dbname = "nextcloud";
                dbuser = "nextcloud";
                defaultPhoneRegion = "DE";
                overwriteProtocol = "https";
              };

              extraOptions = {
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
                  ensurePermissions = {
                    "DATABASE nextcloud" = "ALL PRIVILEGES";
                  };
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
