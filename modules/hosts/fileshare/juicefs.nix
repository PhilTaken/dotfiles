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
in
{
  options.phil.fileshare.juicefs = {
    enable = lib.mkEnableOption "juicefs";

    # TODO auto-create bucket?
    bucket = lib.mkOption {
      description = "bucket name to store data in";
      type = lib.types.str;
      default = "juicefs-data";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.juicefs ];
    services.redis.servers.juicefs = {
      enable = true;
      port = redis_port;
      appendOnly = true;
      settings.dir = "/var/lib/redis-juicefs";

      # allow connections from headscale interface
      settings.protected-mode = "no";
      bind = netlib.thisNode.network_ip."headscale";
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ redis_port ];
    networking.firewall.interfaces."tailscale0".allowedUDPPorts = [ redis_port ];
  };
}
