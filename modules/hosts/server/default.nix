{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server;
in
{
  options.phil.server = {
    enable = mkEnableOption "server module";

    sshKeys = mkOption {
      description = "ssh keys for root user";
      type = types.listOf types.str;
      default = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoABVjBx1az00D8EBjw9/NS9luqO2lN4Y87/2xsQqPTx9P7aXzfX53TwmU9Wpmp7qOIKykd8GSkBdCizMEzgaGmJl6+Di2GYvEfN0NrsLdBrjmIh7AQyR6UbY7qoTFjZ28864rk9QV9to2R1APL7o1wzdmCrFtTsemV+lw9MglqcPLT+ae2mba9fD84FFDmcSJMg5x1QHrO5GuWg/Ng7SE1eRhDbDmz66+HhdgvRRDJ9VwPGcH5ruXsDKvi/nrLVSxw7afvuM5KcNYoy+9CrA/N10cO5zdn4/q2DLYujkOvAucCDJ4bUEe8q6xEZw1LfCjKWIoFxzt+hetfkjS/Y3wWWTcHfcOx/BV6cOxyAFUGbu9RX/iUpyt8LAfjQv6L1zcD7vxYpfKz88jI/4zL7mHwILg+XQklBeiBsEQ4PyO1+4oIfuju241hVk+bFZYUD+AzzCNv7GKNNHe4aa4MWN6RLLhNxe9QlOTnsw0l2XNypr62Q1V8nxZkSY7mW8Hn0hLxTT82mTLuAff2yHPu+w+i0ELkk0BO28apxU1dPPbScHvojRlXTwIBvH3HN6TWdj2YnNFMdGvZgxxFNbi4l/7Gar1FKgi79KOwcm89ATmjONfbQMub+TaeBACefMZ9Q7uzbWeNO3mZpVA8nvM5eleqLemxYoeAQBuYjBjJlAHzQ== cardno:000614321676"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCoABVjBx1az00D8EBjw9/NS9luqO2lN4Y87/2xsQqPTx9P7aXzfX53TwmU9Wpmp7qOIKykd8GSkBdCizMEzgaGmJl6+Di2GYvEfN0NrsLdBrjmIh7AQyR6UbY7qoTFjZ28864rk9QV9to2R1APL7o1wzdmCrFtTsemV+lw9MglqcPLT+ae2mba9fD84FFDmcSJMg5x1QHrO5GuWg/Ng7SE1eRhDbDmz66+HhdgvRRDJ9VwPGcH5ruXsDKvi/nrLVSxw7afvuM5KcNYoy+9CrA/N10cO5zdn4/q2DLYujkOvAucCDJ4bUEe8q6xEZw1LfCjKWIoFxzt+hetfkjS/Y3wWWTcHfcOx/BV6cOxyAFUGbu9RX/iUpyt8LAfjQv6L1zcD7vxYpfKz88jI/4zL7mHwILg+XQklBeiBsEQ4PyO1+4oIfuju241hVk+bFZYUD+AzzCNv7GKNNHe4aa4MWN6RLLhNxe9QlOTnsw0l2XNypr62Q1V8nxZkSY7mW8Hn0hLxTT82mTLuAff2yHPu+w+i0ELkk0BO28apxU1dPPbScHvojRlXTwIBvH3HN6TWdj2YnNFMdGvZgxxFNbi4l/7Gar1FKgi79KOwcm89ATmjONfbQMub+TaeBACefMZ9Q7uzbWeNO3mZpVA8nvM5eleqLemxYoeAQBuYjBjJlAHzQ== (none)"
      ];
    };

    services = {
      fail2ban.enable = mkEnableOption "fail2ban ssh login blocker";
      openssh.enable = mkEnableOption "the ssh daemon";
      jellyfin.enable = mkEnableOption "jellyfin media host";

      grafana = {
        enable = mkEnableOption "grafana dashboard";
      };

      ttrss = {
        enable = mkEnableOption "tiny tiny rss";
        url = mkOption {
          description = "ttrss url (webinterface)";
          type = types.str;
        };
      };

      adguardhome = {
        enable = mkEnableOption "adguard home dns ad blocker";
        url = mkOption {
          description = "adguardhome url (webinterface)";
          type = types.str;
        };
      };

      vaultwarden = {
        enable = mkEnableOption "vaultwarden - selfhosted bitwarden";
        url = mkOption {
          description = "vaultwarden url (webinterface)";
          type = types.str;
        };
      };

      influxdb2 = {
        enable = mkEnableOption "influxdb2 - time series database";
        url = mkOption {
          description = "influxdb url (webinterface)";
          type = types.str;
        };

        port = mkOption {
          description = "influxdb port (webinterface)";
          type = types.port;
          default = 8086;
        };
      };

      telegraf = {
        enable = mkEnableOption "telegraf metric reporting";
      };

      photoprism = {
        enable = mkEnableOption "photoprism picture service";
      };
    };
  };

  config = mkIf (cfg.enable) {
    # -----------------------------------------------

    # fail2ban
    environment.systemPackages = with pkgs; [
      hdparm
      htop
      usbutils
    ] ++ (if cfg.services.fail2ban.enable then [ fail2ban ] else [ ]);


    services.fail2ban.enable = cfg.services.fail2ban.enable;

    # -----------------------------------------------

    # general open ssh config
    services.openssh = {
      enable = cfg.services.openssh.enable;
      passwordAuthentication = false;
      permitRootLogin = "yes";
      authorizedKeysFiles = [ "/etc/nixos/authorized-keys" ];
    };

    # and set some ssh keys for root
    users.extraUsers.root.openssh.authorizedKeys.keys = mkIf (cfg.services.openssh.enable) cfg.sshKeys;

    # -----------------------------------------------

    services.jellyfin = {
      enable = cfg.services.jellyfin.enable;
      openFirewall = true;
    };

    # -----------------------------------------------

    # rss client
    services.tt-rss = {
      enable = cfg.services.ttrss.enable;
      auth = {
        autoCreate = true;
        autoLogin = true;
      };
      registration.enable = false;
      selfUrlPath = "https://rss.pherzog.xyz";
      virtualHost = "rss.pherzog.xyz";
      themePackages = with pkgs; [ tt-rss-theme-feedly ];
    };

    # -----------------------------------------------

    # dns ad blocking
    services.adguardhome = {
      enable = cfg.services.adguardhome.enable;
      host = "http://127.0.0.1";
      port = 31111;
      openFirewall = false;
    };

    # -----------------------------------------------

    sops.secrets.vaultwarden-adminToken = { };
    sops.secrets.vaultwarden-yubicoClientId = { };
    sops.secrets.vaultwarden-yubicoSecretKey = { };

    services.vaultwarden = {
      enable = cfg.services.vaultwarden.enable;
      config = {
        domain = "vault.pherzog.xyz";
        rocketPort = 31113;

        #rocketTls = "{certs=\"/path/to/certs.pem\",key=\"/path/to/key.pem\"}";
        signupsAllowed = true;
        rocketLog = "critical";

        yubicoClientId = config.sops.secrets.vaultwarden-yubicoClientId.path;
        yubicoSecretKey = config.sops.secrets.vaultwarden-yubicoSecretKey.path;
        adminToken = config.sops.secrets.vaultwarden-adminToken.path;
      };
    };

    # -----------------------------------------------

    sops.secrets.telegraf-shared = mkIf (cfg.services.telegraf.enable) {
      owner = config.systemd.services.telegraf.serviceConfig.User;
      sopsFile = ../../../sops/telegraf.yaml;
    };

    services.telegraf = {
      enable = cfg.services.telegraf.enable;
      environmentFiles = [ config.sops.secrets.telegraf-shared.path ];
      extraConfig = {
        agent = {
          interval = "10s";
          round_interval = true;
          metric_batch_size = 1000;
          metric_buffer_limit = 10000;
          collection_jitter = "0s";
          flush_interval = "10s";
          flush_jitter = "0s";
          precision = "";
          debug = false;
          quiet = false;
          logfile = "";
          hostname = "";
          omit_hostname = false;
        };

        outputs = {
          influxdb_v2 = {
            urls = [ "http://alpha.yggdrasil.vpn:8086" ];
            token = "$INFLUX_TOKEN";
            organization = "home";
            bucket = "data";
          };
        };

        inputs = {
          cpu = {
            percpu = true;
            totalcpu = true;
            collect_cpu_time = false;
            report_active = false;
          };

          disk = {
            ignore_fs = [ "tmpfs" "devtmpfs" "devfs" "overlay" "aufs" "squashfs" ];
          };

          diskio = { };
          mem = { };
          net = { };
          processes = { };
          swap = { };
          system = { };
        };
      };
    };

    # -----------------------------------------------

    services.influxdb2 = {
      enable = cfg.services.influxdb2.enable;
      settings = {
        reporting-disable = true;
        http-bind-address = "${cfg.services.influxdb2.url}:${builtins.toString cfg.services.influxdb2.port}";
        #vault-addr = "10.100.0.1:8200";
      };
    };

    # -----------------------------------------------

    virtualisation.oci-containers.containers = mkIf (cfg.services.photoprism.enable) {
      photoprism = {
        image = "photoprism/photoprism:latest";
        ports = [ "127.0.0.1:2342:2342" ];
        volumes = [
          "~/Pictures:/photoprism/originals"
          "~/Import:/photoprism/import"
          "~/storage:/photoprism/storage"
        ];
        environment = {
          PHOTOPRISM_ADMIN_PASSWORD = "insecure"; # PLEASE CHANGE: Your initial admin password (min 4 characters)
          PHOTOPRISM_SITE_URL = "http://localhost:2342/"; # Public server URL incl http:// or https:// and /path, :port is optional
          PHOTOPRISM_ORIGINALS_LIMIT = "1000000"; # File size limit for originals in MB (increase for high-res video)
          PHOTOPRISM_HTTP_COMPRESSION = "none"; # Improves transfer speed and bandwidth utilization (none or gzip)
          PHOTOPRISM_WORKERS = "2"; # Limits the number of indexing workers to reduce system load
          PHOTOPRISM_DEBUG = "false"; # Run in debug mode (shows additional log messages)
          PHOTOPRISM_PUBLIC = "false"; # No authentication required (disables password protection)
          PHOTOPRISM_READONLY = "false"; # Don't modify originals directory (reduced functionality)
          PHOTOPRISM_EXPERIMENTAL = "false"; # Enables experimental features
          PHOTOPRISM_DISABLE_CHOWN = "false"; # Disables storage permission updates on startup
          PHOTOPRISM_DISABLE_WEBDAV = "false"; # Disables built-in WebDAV server
          PHOTOPRISM_DISABLE_SETTINGS = "false"; # Disables Settings in Web UI
          PHOTOPRISM_DISABLE_TENSORFLOW = "false"; # Disables all features depending on TensorFlow
          PHOTOPRISM_DISABLE_FACES = "false"; # Disables facial recognition
          PHOTOPRISM_DISABLE_CLASSIFICATION = "false"; # Disables image classification
          PHOTOPRISM_DARKTABLE_PRESETS = "true"; # Enables Darktable presets and disables concurrent RAW conversion
          # PHOTOPRISM_FFMPEG_ENCODER = "h264_v4l2m2m";       # FFmpeg AVC encoder for video transcoding (default: libx264)
          # PHOTOPRISM_FFMPEG_BUFFERS = "64";                 # FFmpeg capture buffers (default: 32)
          PHOTOPRISM_DETECT_NSFW = "false"; # Flag photos as private that MAY be offensive
          PHOTOPRISM_UPLOAD_NSFW = "true"; # Allow uploads that MAY be offensive
          # PHOTOPRISM_DATABASE_DRIVER = "sqlite";            # SQLite is an embedded database that doesn't require a server
          PHOTOPRISM_DATABASE_DRIVER = "mysql"; # Use MariaDB 10.5+ or MySQL 8+ instead of SQLite for improved performance
          PHOTOPRISM_DATABASE_SERVER = "mariadb:3306"; # MariaDB or MySQL database server (hostname:port)
          PHOTOPRISM_DATABASE_NAME = "photoprism"; # MariaDB or MySQL database schema name
          PHOTOPRISM_DATABASE_USER = "photoprism"; # MariaDB or MySQL database user name
          PHOTOPRISM_DATABASE_PASSWORD = "insecure"; # MariaDB or MySQL database user password
          PHOTOPRISM_SITE_TITLE = "PhotoPrism";
          PHOTOPRISM_SITE_CAPTION = "Browse Your Life";
          PHOTOPRISM_SITE_DESCRIPTION = "";
          PHOTOPRISM_SITE_AUTHOR = "";
          ## Set a non-root user, group, or custom umask if your Docker environment doesn't support this natively =
          # PHOTOPRISM_UID = 1000
          # PHOTOPRISM_GID = 1000
          # PHOTOPRISM_UMASK = 0000
          HOME = "/photoprism";
        };
      };

      mariadb = {
        image = "arm64v8/mariadb:10.6";
        #command: mysqld --transaction-isolation=READ-COMMITTED --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci --max-connections=512 --innodb-rollback-on-timeout=OFF --innodb-lock-wait-timeout=120
        volumes = [
          "./database:/var/lib/mysql" # Never remove
        ];
        environment = {
          MYSQL_ROOT_PASSWORD = "insecure";
          MYSQL_DATABASE = "photoprism";
          MYSQL_USER = "photoprism";
          MYSQL_PASSWORD = "insecure";
        };
      };
    };

    # -----------------------------------------------

    # firewall
    networking.firewall.interfaces = {
      "eth0" = {
        allowedTCPPorts = [
          #80    # to get certs (let's encrypt)
          #443   # ---- " ----
        ];
      };

      "tailscale0" = {
        allowedTCPPorts = [
          53 # dns (adguard home)
          51820 # innernet
          31111 # adguard home webinterface
          25565 # minecraft
        ];

        allowedUDPPorts = [
          53 # dns (adguard home)
          51820
          25565 # minecraft
        ];
      };

      "yggdrasil" = {
        allowedUDPPorts = [
          5353 # dns
          51820 # innernet
          25565 # minecraft
          cfg.services.influxdb2.port
        ];

        allowedTCPPorts = [
          53 # dns (adguard home)
          80 # tt-rss webinterface
          443 # tt-rss ssl
          51820 # innernet
          31111 # adguard home webinterface
          25565 # minecraft
          cfg.services.influxdb2.port
        ];
      };
    };
  };
}
