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
          description = "vaultwarden url (webinterface)";
          type = types.str;
        };
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
    ] ++ (if cfg.services.fail2ban.enable then [ fail2ban ] else []);


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

    services.influxdb2 = {
      enable = cfg.services.influxdb2.enable;
      settings = {
        reporting-disable = true;
        #http-bind-address = "10.100.0.1:8086";
        #vault-addr = "10.100.0.1:8200";
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

      "valhalla" = {
        allowedUDPPorts = [
          5353 # dns
          51820 # innernet
          25565 # minecraft
        ];

        allowedTCPPorts = [
          53 # dns (adguard home)
          80 # tt-rss webinterface
          443 # tt-rss ssl
          51820 # innernet
          31111 # adguard home webinterface
          25565 # minecraft
        ];
      };
    };
  };
}
