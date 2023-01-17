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
    mkIf cfg.enable {
      sops.secrets.nextcloud-adminpass = {
        mode = "777";
      };

      networking.nat = {
        enable = true;
        internalInterfaces = [ "ve-+" ];
        externalInterface = "enp1s0";
      };

      phil.server.services.caddy.proxy."nextcloud" = { ip = localAddress; inherit port; };

      containers.nextcloud =
        let
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

          config = { config, pkgs, ... }: {
            # https://github.com/NixOS/nixpkgs/issues/162686
            networking.nameservers = [ "1.1.1.1" ];
            # WORKAROUND
            environment.etc."resolv.conf".text = "nameserver 1.1.1.1";

            networking.firewall.enable = false;

            services.nextcloud = {
              enable = true;
              package = pkgs.nextcloud25;

              inherit home datadir;
              hostName = "${cfg.host}.pherzog.xyz";
              https = true;

              extraApps = {
                calendar = pkgs.fetchzip {
                  url = "https://github.com/nextcloud/calendar/archive/refs/tags/v3.3.2.tar.gz";
                  sha256 = "sha256-I39pTEwotYj52BAdMZfP+o6zxPxBtxsIL82FNoR9fOQ=";
                };
                news = pkgs.fetchNextcloudApp {
                  url = "https://github.com/nextcloud/news/releases/download/20.0.0/news.tar.gz";
                  sha256 = "sha256-p3Ft3sQ/2HPXCFE03dm8pBL39b7bWCi2iAxHkbOK2V4=";
                };
                deck = pkgs.fetchNextcloudApp {
                  url = "https://github.com/nextcloud/deck/releases/download/v1.8.3/deck.tar.gz";
                  sha256 = "sha256-5dW5sZzz+Ff129ZxgbmVQBGFIUNE7vTStNwULP7KaA8=";
                };
                bookmarks = pkgs.fetchNextcloudApp {
                  url = "https://github.com/nextcloud/bookmarks/releases/download/v12.0.0/bookmarks-12.0.0.tar.gz";
                  sha256 = "sha256-vQvatq162L/tOI0yoCkWGVv/T1N6oIB19Xlav5ySbjY=";
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

              #phpOptions = {
              #redis.host = config.services.redis.servers.nextcloud.unixSocket;
              #redis.port = "0";
              #redis.dbindex = "0";
              #redis.timeout = "1.5";
              #};
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
