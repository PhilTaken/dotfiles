{
  config,
  lib,
  net,
  npins,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.freshrss;

  # todo better way to assign ips + ports to avoid collisions
  # maybe assign ports in network.nix?
  hostAddress = "192.0.0.1";
  localAddress = "192.0.0.3";
in {
  options.phil.server.services.freshrss = {
    enable = mkEnableOption "freshrss";
    url = mkOption {
      description = "freshrss url (webinterface)";
      default = "https://rss.${net.tld}";
      type = types.str;
    };

    host = mkOption {
      type = types.str;
      default = "rss";
    };

    port = mkOption {
      type = types.port;
      default = 3333;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.freshrss-password = {};

    networking.nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      externalInterface = "enp1s0";
    };

    networking.firewall.interfaces."${net.networks.default.interfaceName}" = {
      allowedUDPPorts = [cfg.port];
      allowedTCPPorts = [cfg.port];
    };

    phil.server.services = {
      caddy.proxy."rss" = {
        inherit (cfg) port;
        public = true;
        proxyPass = "http://${net.networks.default.hosts.${config.networking.hostName}}:${builtins.toString cfg.port}";
      };
      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "FreshRSS";
          subtitle = "RSS feeds";
          tag = "app";
          keywords = "selfhosted cloud rss";
          logo = "https://freshrss.org/card.png";
        };
      };
    };

    containers.freshrss = let
      adminpassFile = config.sops.secrets.freshrss-password.path;
    in {
      ephemeral = false;
      autoStart = true;

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

        "/var/lib/freshrss/extensions" = {
          hostPath = "${npins.freshrss_extensions}";
          isReadOnly = true;
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

        services.freshrss = {
          enable = true;
          baseUrl = cfg.url;
          defaultUser = "phil";
          passwordFile = adminpassFile;
          virtualHost = "freshrss";
        };
      };
    };
  };
}
