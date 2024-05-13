{
  config,
  lib,
  net,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.freshrss;

  # TODO fixed release since ?
  freshrss_extensions = builtins.fetchTarball {
    name = "freshrss-extensions";
    url = "https://github.com/FreshRSS/Extensions/archive/master.zip";
    sha256 = "sha256:0p3j0gk25ddh4k0yqqagpxkxcyi8pc7x7c8snbssvljh5q6v7xcy";
  };

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
    sops.secrets.freshrss-password.mode = "777";

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
      extensions_path = "/var/lib/freshrss/extensions";
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

      bindMounts =
        {
          ${adminpassFile} = {
            hostPath = adminpassFile;
            isReadOnly = true;
          };
        }
        // (builtins.listToAttrs (builtins.map (extension: {
            name = "${extensions_path}/${extension}";
            value = {
              hostPath = "${freshrss_extensions}/${extension}";
              isReadOnly = true;
            };
          }) [
            "xExtension-ColorfulList"
            "xExtension-CustomCSS"
            "xExtension-ReadingTime"
            "xExtension-showFeedID"
            "xExtension-YouTube"
          ]));

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

        # https://github.com/NixOS/nixpkgs/pull/307459
        systemd.services.freshrss-config.environment.THIRDPARTY_EXTENSIONS_PATH = extensions_path;
        systemd.services.freshrss-updater.environment.THIRDPARTY_EXTENSIONS_PATH = extensions_path;
        services.phpfpm.pools.freshrss.phpEnv.THIRDPARTY_EXTENSIONS_PATH = extensions_path;

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
