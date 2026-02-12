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

    mounts = lib.mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = lib.mkMerge [
    # server
    (lib.mkIf cfg.server.enable {
      environment.systemPackages = [ pkgs.juicefs ];
      services.redis.servers.juicefs = {
        enable = true;
        port = redis_port;
        appendOnly = true;
        settings.dir = "/var/lib/redis-juicefs";

        # allow connections from headscale interface
        settings.protected-mode = "no";
        bind = netlib.thisNode.network_ip.${network};
      };

      networking.firewall.interfaces.${interface} = {
        allowedTCPPorts = [ redis_port ];
        allowedUDPPorts = [ redis_port ];
      };
    })

    # clients
    {
      # This enables the FUSE kernel module and installs the necessary binaries
      #boot.supportedFilesystems = [ "fuse" ];

      programs.fuse.userAllowOther = true;

      systemd.tmpfiles.rules = [
        "d '/shared' 0777 - - - -"
      ];

      systemd.mounts = builtins.map (key: {
        where = "/shared/${key}";
        what = redis_url;
        options = "_netdev,allow_other,writeback_cache,subdir=/${key}";
        type = "juicefs";
        mountConfig.Environment = "AWS_REGION=garage";
      }) cfg.mounts;

      systemd.automounts = builtins.map (key: {
        description = "Automount for /shared/${key} on NAS";
        where = "/shared/${key}";
        wantedBy = [ "multi-user.target" ];
      }) cfg.mounts;
    }
  ];
}
