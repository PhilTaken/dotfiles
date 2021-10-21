{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.webapps;
in
{
  options.phil.webapps = {
    enable = mkOption {
      description = "enable webapps module";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) rec {
    sops.secrets.vaultwarden-adminToken = { };
    sops.secrets.vaultwarden-yubicoClientId = { };
    sops.secrets.vaultwarden-yubicoSecretKey = { };

    # ---------------------------------------------------- #
    # TODO move into separate modules

    # rss client
    services.tt-rss = {
      enable = true;
      auth = {
        autoCreate = true;
        autoLogin = true;
      };
      registration.enable = false;
      selfUrlPath = "https://rss.pherzog.xyz";
      virtualHost = "rss.pherzog.xyz";

      themePackages = with pkgs; [ tt-rss-theme-feedly ];
    };

    # dns ad blocking
    services.adguardhome = {
      enable = true;
      host = "http://127.0.0.1";
      port = 31111;
      openFirewall = false;
    };

    services.vaultwarden = {
      enable = false;
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
          80 # tt-rss webinterface
          443 # tt-rss ssl
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
