{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.nextcloud;
in
{
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

  config =
    let
      port = 80;
      hostAddress = "192.0.0.1";
      localAddress = "192.0.0.2";
    in
    mkIf (cfg.enable) {
      sops.secrets.nextcloud-adminpass = {
        mode = "777";
      };

      networking.nat = {
        enable = mkDefault cfg.enable;
        internalInterfaces = [ "ve-*" ];
        externalInterface = "enp1s0";
      };

      phil.server.services.caddy.proxy."nextcloud" = { ip = localAddress; inherit port; };

      containers.nextcloud =
        let
          adminpassFile = config.sops.secrets.nextcloud-adminpass.path;
          home = "/media/nextcloud";
          datadir = "/var/lib/nextcloud";
        in
        mkIf (cfg.enable) {
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

          config = { config, pkgs, ... }: {
            networking.firewall.enable = false;

            services.nextcloud = {
              enable = true;
              package = pkgs.nextcloud24;

              inherit home datadir;
              hostName = "${cfg.host}.pherzog.xyz";
              https = true;

              extraApps = {
                talk = pkgs.fetchNextcloudApp {
                  name = "spreed";
                  sha256 = "sha256-sMEH22UWoyRoo6whJ9Eh/CVYOIAXtQ8U8XvkDoKExc0=";
                  url = "https://github.com/nextcloud-releases/spreed/releases/download/v14.0.2/spreed-v14.0.2.tar.gz";
                  version = "14.0.2";
                };
                calendar = pkgs.fetchNextcloudApp {
                  name = "calendar";
                  sha256 = "sha256-c+iiz/pRs7fw2+DneSODWENRnZPZ2BDRa6dOjicABMY=";
                  url = "https://github.com/nextcloud/calendar/archive/refs/tags/v3.3.2.tar.gz";
                  version = "3.3.2";
                };
                news = pkgs.fetchNextcloudApp {
                  name = "news";
                  sha256 = "sha256-jmrocdJmRpau0zV8UtLyvrlX/k7O6zlZ8G9zry8ibEw=";
                  url = "https://github.com/nextcloud/news/releases/download/18.1.0/news.tar.gz";
                  version = "18.1.0";
                };
                deck = pkgs.fetchNextcloudApp {
                  name = "deck";
                  sha256 = "sha256-qIM6NvOP/1LlIqeQlImmrG6kPHbrF2O1E0yAQCJNDh4=";
                  url = "https://github.com/nextcloud/deck/releases/download/v1.7.0/deck.tar.gz";
                  version = "1.7.0";
                };
                bookmarks = pkgs.fetchNextcloudApp {
                  name = "bookmarks";
                  sha256 = "sha256-v3Ug4zdmjWGsFTf6epI4fis6f8rQ43WD65Dy/Ife4kI=";
                  url = "https://github.com/nextcloud/bookmarks/releases/download/v10.5.1/bookmarks-10.5.1.tar.gz";
                  version = "10.5.1";
                };
              };

              caching.redis = true;
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
              ensureDatabases = [ "nextcloud" ];
            };

            services.redis.servers.nextcloud.enable = true;
            services.redis.servers.nextcloud.unixSocketPerm = 770;

            users.users.nginx.extraGroups = [ "redis-nextcloud" ];
            users.users.nextcloud.extraGroups = [ "redis-nextcloud" ];

            system.stateVersion = "22.11";
          };
        };
    };
}
