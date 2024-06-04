{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.phil.nebula;
  hostname = config.networking.hostName;

  net = config.phil.network;
  networkName = "milkyway";
  port = 4242;

  hostMap =
    builtins.listToAttrs
    (map
      (endp: {
        name = net.nodes.${endp}.network_ip.${networkName};
        value = [(net.nodes.${endp}.public_ip + ":${toString port}")];
      })
      (builtins.attrNames (lib.filterAttrs (_n: v: v.public_ip != null) net.nodes)));

  isLighthouse = net.nodes.${hostname} ? "public_ip";

  lighthouses =
    if isLighthouse
    then []
    else builtins.attrNames hostMap;

  sopsConfig = {
    owner = config.systemd.services."nebula@${networkName}".serviceConfig.User or "root";
    sopsFile = ../../../sops/machines + "/${hostname}.yaml";
  };

  # TODO: rework this
  any = {
    port = "any";
    proto = "any";
    host = "any";
  };
in {
  options.phil.nebula.enable = mkEnableOption "nebula";
  config = mkIf cfg.enable {
    sops.secrets.ca = {
      inherit (sopsConfig) owner;
      sopsFile = ../../../sops/nebula.yaml;
    };
    sops.secrets."nebula-key" = sopsConfig;
    sops.secrets."nebula-crt" = sopsConfig;

    services.nebula.networks."${networkName}" = {
      inherit (cfg) enable;
      inherit lighthouses isLighthouse;

      ca = config.sops.secrets.ca.path;
      key = config.sops.secrets."nebula-key".path;
      cert = config.sops.secrets."nebula-crt".path;

      tun.device = networkName;
      staticHostMap = hostMap;

      firewall.inbound = [any];
      firewall.outbound = [any];

      settings = {
        cipher = "aes";
        tun.mtu = 2000;
        tun.tx_queue = 5000;
        listen.write_buffer = 10485760;
        listen.read_buffer = 10485760;
        listen.batch = 128;
      };
    };
  };
}
