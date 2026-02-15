{ netlib, ... }:
let
  mimos-port = netlib.portFor "redis-mimos";
  network = "headscale";
  interface = netlib.networks.${network}.ifname;
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  virtualisation.docker.enable = true;

  # ----------------------------------------------------

  # TODO reenable when twisted is fixed
  # or rewrite it in a sane language ...
  phil.server.services.promexp.extrasensors = false;

  phil.fileshare = {
    nfs.shares.dirs = [ "/media" ];

    samba = {
      enable = true;
      share_dir = "/media/mount/tl/sims";
    };

    garage = {
      enable = true;
      data_dir = "/media/garage";
    };

    juicefs.server = {
      enable = true;
      bucket = "juicefs-data";
    };
  };

  # ----------------------------------------------------

  services.redis.servers.mimos = {
    enable = true;
    port = mimos-port;
    settings.dir = "/var/lib/redis-mimos";
    # allow connections from headscale interface
    settings.protected-mode = "no";
    bind = netlib.thisNode.network_ip.${network};
  };

  networking.firewall.interfaces.${interface} = {
    allowedTCPPorts = [ mimos-port ];
    allowedUDPPorts = [ mimos-port ];
  };

  # ----------------------------------------------------

  networking.hostId = "ef45f308";
  system.stateVersion = "22.05";
}
