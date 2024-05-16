# TODO remove this module
{
  net,
  lib,
  ...
}: let
  inherit (lib) mergeAttrs mapAttrs;

  network = net.networks.yggdrasil;
  iplot = network.hosts;

  mkOwnIPs = host: ["${iplot.${host}}/24"];
  mkAllowedIPs = host: ["${iplot.${host}}/32"];

  mkPeer = {
    host,
    publicKey,
  }:
    mergeAttrs
    {
      inherit publicKey;
      ownIPs = mkOwnIPs host;
      allowedIPs = mkAllowedIPs host;
    }
    (
      if builtins.hasAttr host net.endpoints
      then {
        allowedIPs = [network.netmask];
        endpoint = net.endpoints.${host};
      }
      else {}
    );

  pubkeys = {
    beta = "/DWBidRPbNdqBhXZJFGpD20K+Bs6ViEbq4DJOlw5f0U=";
    gamma = "1w8CC/pEfXFPvdzyspDkuw/s8k2bkqAqk4KKg35IvQc=";
    delta = "598UtHyLn0L5ReObBtsT+UAJHtt7FtuFZiF5nRJ+nEg=";
    epsilon = "Xbi0ylobPYxxcxCvxaJ2mvC2WqGlODnMkeIYPG9tlVo=";
  };
in
  mapAttrs (host: publicKey: mkPeer {inherit host publicKey;}) pubkeys
