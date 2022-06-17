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
          datadir = "/media";
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
          };

          config = { config, pkgs, ... }: {
            networking.firewall.enable = false;

            services.nextcloud = {
              enable = true;
              package = pkgs.nextcloud24;
              hostName = "nextcloud.home";
              caching.redis = true;
              home = datadir;
              config = {
                adminuser = "admin";
                inherit adminpassFile;
                dbtype = "pgsql";
                dbhost = "/run/postgresql";
                dbname = "nextcloud";
                dbuser = "nextcloud";
                defaultPhoneRegion = "DE";
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
