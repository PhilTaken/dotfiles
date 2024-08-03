{
  config,
  lib,
  netlib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.phil.server.services.grocy;

  datadir = "/var/lib/grocy";
in {
  options.phil.server.services.grocy = {
    enable = mkEnableOption "grocy";
    host = mkOption {
      type = types.str;
      default = "grocy";
    };

    port = mkOption {
      type = types.port;
      default = netlib.portFor "grocy";
    };
  };

  config = mkIf cfg.enable {
    # TODO back up grocy database
    systemd.tmpfiles.rules = ["d '${datadir}' - - - - -"];

    containers.grocy = let
      hostAddress = "192.0.2.1";
      localAddress = "192.0.2.2";
    in
      mkIf cfg.enable {
        ephemeral = true;
        autoStart = true;

        #privateNetwork = false;
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
          ${datadir} = {
            hostPath = datadir;
            isReadOnly = false;
          };
        };

        config = {...}: {
          # https://github.com/NixOS/nixpkgs/issues/162686
          networking.nameservers = ["1.1.1.1"];
          # WORKAROUND
          environment.etc."resolv.conf".text = "nameserver 1.1.1.1";
          networking.firewall.enable = false;
          system.stateVersion = "22.11";

          services.grocy = {
            enable = true;
            hostName = netlib.domainFor cfg.host;
            nginx.enableSSL = false;
            settings = {
              currency = "EUR";
              calendar.firstDayOfWeek = 1;
            };
          };
        };
      };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {
        inherit (cfg) port;
      };

      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Grocy";
          subtitle = "Grocery managment service";
          tag = "grocery";
          keywords = "selfhosted grocery food";
          logo = "https://grocy.info/img/grocy_logo.svg";
        };
      };
    };
  };
}
