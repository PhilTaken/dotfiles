{
  config,
  netlib,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.phil.fileshare.juicefs;
  redis_port = netlib.portFor "redis-juicefs";

  inherit (lib) types;

  network = "headscale";
  interface = netlib.networks.${network}.ifname;

  # TODO don't hardcode delta
  redis_host = "delta";
  redis_url = "redis://${
    netlib.nodes.${redis_host}.network_ip.${network}
  }:${builtins.toString redis_port}/0";
in
{
  options.phil.fileshare.juicefs = {
    # TODO auto-create bucket?
    server.enable = lib.mkEnableOption "juicefs";
    server.bucket = lib.mkOption {
      description = "bucket name to store data in";
      type = types.str;
      default = "juicefs-data";
    };

    mount_root = lib.mkOption {
      type = types.bool;
      default = false;
    };

    mounts = lib.mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = lib.mkMerge [
    # clients
    (lib.mkIf (cfg.mounts != [ ] || cfg.mount_root) {
      assertions = [
        {
          assertion = builtins.length cfg.mounts == 0 || cfg.mount_root;
          message = "cannot mount both individual juicefs mounts and the juicefs root at the same time";
        }
      ];

      systemd.tmpfiles.rules = [
        "d '/shared' 0777 - - - -"
      ];

      #boot.supportedFilesystems = [ "fuse" ];
      environment.systemPackages = [ pkgs.juicefs ];
      programs.fuse.userAllowOther = true;
    })

    # use regular systemd services instead?
    (lib.mkIf (cfg.mounts != [ ]) {
      systemd.mounts = builtins.map (key: {
        where = "/shared/${key}";
        what = redis_url;
        options = "_netdev,allow_other,writeback_cache,subdir=/${key},cache-dir=/var/cache/juicefs-${key}";
        type = "juicefs";
        mountConfig.Environment = "AWS_REGION=garage";
      }) cfg.mounts;

      systemd.automounts = builtins.map (key: {
        description = "Automount for /shared/${key} on NAS";
        where = "/shared/${key}";
        wantedBy = [ "multi-user.target" ];
      }) cfg.mounts;
    })

    (lib.mkIf cfg.mount_root {
      systemd.mounts = [
        {
          where = "/shared";
          what = redis_url;
          options = "_netdev,allow_other,writeback_cache,cache-dir=/var/cache/juicefs";
          type = "juicefs";
          mountConfig.Environment = "AWS_REGION=garage";
        }
      ];

      systemd.automounts = [
        {
          description = "Automount for /shared on NAS";
          where = "/shared";
          wantedBy = [ "multi-user.target" ];
        }
      ];
    })

    # server
    (lib.mkIf cfg.server.enable {
      environment.systemPackages = [ pkgs.juicefs ];
      services.redis.servers.juicefs = {
        enable = true;
        port = redis_port;
        appendOnly = true;
        settings.dir = "/var/lib/redis-juicefs";
        save = [ ];

        # allow connections from headscale interface
        settings.protected-mode = "no";
        bind = netlib.thisNode.network_ip.${network};
      };

      networking.firewall.interfaces.${interface} = {
        allowedTCPPorts = [ redis_port ];
        allowedUDPPorts = [ redis_port ];
      };
    })
  ];
}
