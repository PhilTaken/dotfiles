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

      photoview = {
        enable = mkEnableOption "photoview picture service";
        port = mkOption {
          description = "port for the photoview webinterface";
          type = types.port;
          default = 2342;
        };
        photoDir = mkOption {
          description = "path to the photoview folder";
          type = types.str;
          default = "/media/Pictures";
        };
      };

      nextcloud = {
        enable = mkEnableOption "nextcloud filesharing server";
        port = mkOption {
          description = "port for the photoview webinterface";
          type = types.port;
          default = 8080;
        };
        home = mkOption {
          description = "nextcloud home path";
          type = types.str;
          default = "/media/nextcloud";
        };
      };

      iperf = {
        enable = mkEnableOption "iperf throughput measuring";
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

    services.iperf3 = {
      enable = cfg.services.iperf.enable;
      openFirewall = true;
    };

    # -----------------------------------------------

    virtualisation.oci-containers.containers."nextcloud" = mkIf (cfg.services.nextcloud.enable) {
      image = "nextcloud";
      ports = [ "${builtins.toString cfg.services.nextcloud.port}:80" ];
      volumes = [
        "${cfg.services.nextcloud.home}:/var/www/html/data"
      ];
      environment = {
        NEXTCLOUD_ADMIN_USER = "admin";
        #                            local         tailscale     yggdrasil
        NEXTCLOUD_TRUSTED_DOMAINS = "192.168.0.120 100.105.96.43 10.100.0.2";
      };
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

    systemd.services.init-photoview-network-and-files = mkIf (cfg.services.photoview.enable) {
      description = "Create the network bridge photoview-br for photoview";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = let
        dockercli = "${config.virtualisation.docker.package}/bin/docker";
      in ''
        # Put a true at the end to prevent getting non-zero return code, which will crash the whole service
        check=$(${dockercli} network ls | grep "photoview-br" || true)
        if [ -z "$check" ]; then
          ${dockercli} network create photoview-br
        else
          echo "photoview-br already exists in docker"
        fi
      '';
    };

    virtualisation.oci-containers.containers."mariadb-photoview" = mkIf (cfg.services.photoview.enable) {
      image = "mariadb:10.5";
      volumes = [
        "db_data:/var/lib/mysql"
      ];
      environment = {
        MYSQL_DATABASE = "photoview";
        MYSQL_USER = "photoview";
        MYSQL_PASSWORD = "photosecret";
        MYSQL_RANDOM_ROOT_PASSWORD = "1";
      };
      extraOptions = [ "--network=photoview-br" ];
    };

    virtualisation.oci-containers.containers."photoview" = mkIf (cfg.services.photoview.enable) {
      image = "viktorstrate/photoview:2";
      ports = [ "${builtins.toString cfg.services.photoview.port}:80" ];
      volumes = [
        "${cfg.services.photoview.photoDir}:/photos"
      ];
      environment = {
        PHOTOVIEW_DATABASE_DRIVER = "mysql";
        PHOTOVIEW_MYSQL_URL = "photoview:photosecret@tcp(mariadb-photoview)/photoview";
        PHOTOVIEW_LISTEN_IP = "photoview";
        PHOTOVIEW_LISTEN_PORT = "80";
        PHOTOVIEW_MEDIA_CACHE = "/app/cache";
      };
      extraOptions = [ "--network=photoview-br" ];
    };

    # -----------------------------------------------

    # firewall
    networking.firewall.interfaces = {
      "eth0" = {
        allowedTCPPorts = [
          #80    # to get certs (let's encrypt)
          #443   # ---- " ----
          cfg.services.photoview.port
        ];

        allowedUDPPorts = [
          cfg.services.photoview.port
        ];
      };

      "tailscale0" = {
        allowedTCPPorts = [
          53 # dns (adguard home)
          25565 # minecraft
          31111 # adguard home webinterface
          51820 # innernet
          cfg.services.photoview.port
        ];

        allowedUDPPorts = [
          53 # dns (adguard home)
          8080 # nextcloud
          25565 # minecraft
          51820
          cfg.services.photoview.port
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
