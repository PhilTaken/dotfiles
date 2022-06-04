{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.nebula;
  networkName = "milkyway";

  net = import ../../../network.nix {};
  iplot = net.networks."${networkName}";
  hostnames = builtins.attrNames iplot;
  hostname = config.networking.hostName;
  port = 4242;

  hostMap = builtins.listToAttrs
    (map
      (endp: {
        name = iplot.${endp};
        value = [ (net.endpoints.${endp} + ":${toString port}") ];
      })
      (builtins.attrNames net.endpoints));

  isLighthouse = builtins.elem hostname (builtins.attrNames net.endpoints);
  lighthouses = if isLighthouse then [] else builtins.attrNames hostMap;

  owner = config.systemd.services."nebula@${networkName}".serviceConfig.User or "root";
  sopsFile = ../../../sops/nebula.yaml;

  # TODO: rework this
  any = { port = "any"; proto = "any"; host = "any"; };
in {
  options.phil.nebula.enable = mkEnableOption "nebula";
  config = mkIf (cfg.enable) {
    sops.secrets.ca = {
      inherit owner sopsFile;
    };
    sops.secrets."${hostname}-key" = {
      inherit owner sopsFile;
    };
    sops.secrets."${hostname}-crt" = {
      inherit owner sopsFile;
    };

    services.nebula.networks."${networkName}" = {
      inherit (cfg) enable;
      inherit lighthouses isLighthouse;

      ca = config.sops.secrets.ca.path;
      key = config.sops.secrets."${hostname}-key".path;
      cert = config.sops.secrets."${hostname}-crt".path;

      staticHostMap = hostMap;
      firewall.inbound = [ any ];
      firewall.outbound = [ any ];
    };
  };
}
