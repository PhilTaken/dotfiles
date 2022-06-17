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

  config = mkIf (cfg.enable) {
    sops.secrets.nextcloud-adminpass = {
      owner = config.users.users.nextcloud.name;
      group = config.users.users.nextcloud.group;
    };

    services.nextcloud = {
      enable = true;
      package = pkgs.nextcloud24;
      hostName = "nextcloud.home";
      https = true;
      webfinger = true;
      caching.redis = true;
      config = {
        adminuser = "admin";
        adminpassFile = config.sops.secrets.nextcloud-adminpass.path;
        dbtype = "pgsql";
        dbhost = "/run/postgresql";
        dbname = "nextcloud";
        dbuser = "nextcloud";
        defaultPhoneRegion = "DE";
      };
    };

    services.postgresql = {
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
  };
}
