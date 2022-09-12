{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.nebula;
  networkName = "milkyway";

  net = import ../../../network.nix { };
  iplot = net.networks."${networkName}";
  hostnames = builtins.attrNames iplot;
  hostname = config.networking.hostName;
  port = 4242;

  hostMap = builtins.listToAttrs
    (map
      (endp: {
        name = iplot.${endp};
        value = [ (net.networks.endpoints.${endp} + ":${toString port}") ];
      })
      (builtins.attrNames net.networks.endpoints));

  isLighthouse = builtins.elem hostname (builtins.attrNames net.networks.endpoints);
  lighthouses = if isLighthouse then [ ] else builtins.attrNames hostMap;

  sopsConfig = {
    owner = config.systemd.services."nebula@${networkName}".serviceConfig.User or "root";
    sopsFile = ../../../sops/nebula.yaml;
  };

  # TODO: rework this
  any = { port = "any"; proto = "any"; host = "any"; };
in
{
  options.phil.nebula.enable = mkEnableOption "nebula";
  config = mkIf cfg.enable {
    sops.secrets.ca = sopsConfig;
    sops.secrets."${hostname}-key" = sopsConfig;
    sops.secrets."${hostname}-crt" = sopsConfig;

    services.nebula.networks."${networkName}" = {
      inherit (cfg) enable;
      inherit lighthouses isLighthouse;

      ca = config.sops.secrets.ca.path;
      key = config.sops.secrets."${hostname}-key".path;
      cert = config.sops.secrets."${hostname}-crt".path;

      tun.device = networkName;
      staticHostMap = hostMap;

      firewall.inbound = [ any ];
      firewall.outbound = [ any ];

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

