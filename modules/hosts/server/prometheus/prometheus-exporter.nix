{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf types mkOption mkEnableOption;
  cfg = config.phil.server.services.promexp;
  net = config.phil.network;
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
      ports = [9002] ++ lib.optional cfg.extrasensors cfg.prom-sensors-port;
    in {
      allowedUDPPorts = ports;
      allowedTCPPorts = ports;
    };

    services.prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = ["systemd" "processes"];
        disabledCollectors = ["arp"];
        port = 9002;
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
