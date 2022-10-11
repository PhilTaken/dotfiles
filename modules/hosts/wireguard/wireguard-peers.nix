{ pkgs
}:
with pkgs.lib;

let
  net = import ../../../network.nix { };
  iplot = net.networks.yggdrasil;
  hostnames = builtins.attrNames iplot;

  mkOwnIPs = host: [ "${iplot.${host}}/24" ];
  mkAllowedIPs = host: [ "${iplot.${host}}/32" ];

  mkPeer = { host, publicKey }: mergeAttrs
    {
      inherit publicKey;
      ownIPs = mkOwnIPs host;
      allowedIPs = mkAllowedIPs host;
    }
    (if builtins.hasAttr host net.networks.endpoints then {
      allowedIPs = [ iplot.gateway ];
      endpoint = net.networks.endpoints.${host};
    } else { });

  pubkeys = {
    alpha = "LDOII0S7OWakg4oDrC1wUCoM/YXq3wXTEjYoqBbI2Sk=";
    beta = "/DWBidRPbNdqBhXZJFGpD20K+Bs6ViEbq4DJOlw5f0U=";
    gamma = "1w8CC/pEfXFPvdzyspDkuw/s8k2bkqAqk4KKg35IvQc=";
    delta = "598UtHyLn0L5ReObBtsT+UAJHtt7FtuFZiF5nRJ+nEg=";
    epsilon = "Xbi0ylobPYxxcxCvxaJ2mvC2WqGlODnMkeIYPG9tlVo=";
  };

in
mapAttrs (host: publicKey: mkPeer { inherit host publicKey; }) pubkeys
