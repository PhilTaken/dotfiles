{ pkgs
, config
, lib
, net
, ...
}:

let
  inherit (lib) mkIf types mkOption mkEnableOption;
  cfg = config.phil.server.services.promexp;
in
{
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

  config = (mkIf cfg.enable {
    networking.firewall.interfaces."${net.networks.default.interfaceName}" = let
      ports = let
        exportPort = lib.mapAttrsToList
          (_: c: c.port)
          (lib.filterAttrs
            (_: c: builtins.typeOf c != "list" && c.enable)
            config.services.prometheus.exporters);
        extraPorts = lib.optionals cfg.prom-sensors-port [ cfg.prom-sensors-port ];
      in exportPort ++ extraPorts;
    in {
      allowedUDPPorts = ports;
      allowedTCPPorts = ports;
    };

    services.prometheus.exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
  }) // (mkIf cfg.extrasensors {
    users.users."sensors-exporter" = {
      description = "Prometheus sensors exporter service user";
      group = "sensors-exporter";
      isSystemUser = true;
      extraGroups = "dialout";
    };
    users.groups."sensors-exporter" = {};

    systemd.services.prometheus-sensor-exporter = let
      mypy = pkgs.python39.withPackages (ps: [
        ps.pyramid
        ps.prometheus-client
        ps.twisted
        ps.pyserial
      ]);
      writeMyPy = name: pkgs.writers.makePythonWriter mypy pkgs.python39Packages pkgs.buildPackages.python39Packages name {};
      pyfile = writeMyPy "prom-sensors.py" ./sensors.py;
    #in mkIf cfg.extrasensors {
    in {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

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

        CapabilityBoundingSet = [ "" ];
        DeviceAllow = [ "" ];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
    };
  });
}
