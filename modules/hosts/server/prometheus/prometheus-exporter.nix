{
  pkgs,
  config,
  lib,
  netlib,
  ...
}: let
  inherit (lib) mkIf types mkOption mkEnableOption;
  cfg = config.phil.server.services.promexp;
  net = config.phil.network;

  exporters = builtins.removeAttrs config.services.prometheus.exporters ["assertions" "warnings" "minio" "tor"];
  enabled_exporters = lib.filterAttrs (_: v: v.enable) exporters;
  exporter_ports = lib.mapAttrsToList (_: v: v.port) enabled_exporters;
in {
  options.phil.server.services.promexp = {
    enable = mkOption {
      default = true;
      type = types.bool;
    };

    extrasensors = mkEnableOption "extra sensors";

    prom-sensors-port = mkOption {
      default = 9003;
      type = types.port;
    };
  };

  config = mkIf cfg.enable {
    # TODO fix this
    networking.firewall.interfaces."${net.networks.headscale.ifname}" = let
      ports = exporter_ports ++ lib.optional cfg.extrasensors cfg.prom-sensors-port;
    in {
      allowedUDPPorts = ports;
      allowedTCPPorts = ports;
    };

    services.prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd" "processes"];
        disabledCollectors = ["arp"];
        port = netlib.portFor "node-exporter";
      };

      zfs = {
        enable = builtins.elem "zfs" (builtins.catAttrs "fsType" (builtins.attrValues config.fileSystems));
        port = netlib.portFor "zfs-exporter";
      };

      smartctl = {
        enable = true;
        maxInterval = "2m";
        port = netlib.portFor "smartctl-exporter";
      };

      unbound = {
        inherit (config.phil.server.services.unbound) enable;
        unbound = {
          ca = null;
          certificate = null;
          key = null;
          host = "unix://${config.services.unbound.localControlSocketPath}";
        };
      };

      ping = {
        enable = true;
        settings = {
          targets = [
            "8.8.8.8"
            "8.8.4.4"
            {"google.com".asn = 15169;}
          ];

          dns = {
            refresh = "2m";
            nameserver = "1.1.1.1";
          };

          ping = {
            interval = "2s";
            timeout = "3s";
            history-size = 50;
            payload-size = 120;
          };

          options.disableIPv6 = false;
        };
      };
    };

    users.users."sensors-exporter" = mkIf cfg.extrasensors {
      description = "Prometheus sensors exporter service user";
      group = "sensors-exporter";
      isSystemUser = true;
      extraGroups = ["dialout"];
    };
    users.groups."sensors-exporter" = mkIf cfg.extrasensors {};

    systemd.services.prometheus-sensor-exporter = let
      mypy = pkgs.python3.withPackages (ps: [
        ps.pyramid
        ps.prometheus-client
        ps.twisted
        ps.pyserial
        ps.setuptools
      ]);
      writeMyPy = name: pkgs.writers.makePythonWriter mypy pkgs.python3Packages pkgs.buildPackages.python3Packages name {};
      pyfile = writeMyPy "prom-sensors.py" ./sensors.py;
    in
      mkIf cfg.extrasensors {
        wantedBy = ["multi-user.target"];
        after = ["network.target"];

        serviceConfig = {
          ExecStart = pkgs.writeShellScript "wsgi" ''
            export PYTHONPATH="${builtins.dirOf pyfile}:$PYTHONPATH"
            ${mypy}/bin/python \
              -m twisted web \
              --listen=tcp:${builtins.toString cfg.prom-sensors-port} \
              --wsgi ${let file = builtins.baseNameOf pyfile; in builtins.substring 0 (builtins.stringLength file - 3) file}.app
          '';

          Restart = "always";
          User = "sensors-exporter";
          Group = "sensors-exporter";

          #RemoveIPC = true;
          #ProtectHome = true;
          #ProtectClock = true;
          #ProtectHostname = true;
          #LockPersonality = true;
          #RestrictRealtime = true;
          #ProtectKernelLogs = true;
          #ProtectControlGroups = true;
          #ProtectKernelModules = true;
          #ProtectKernelTunables = true;
          #MemoryDenyWriteExecute = true;

          #UMask = "0077";
          #SystemCallArchitectures = "native";
          #RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        };
      };
  };
}
