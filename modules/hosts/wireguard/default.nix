{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.wireguard;
  hostname = config.networking.hostName;

  peers = import ./wireguard-peers.nix;
  mkPeer = { publicKey, ownIPs, allowedIPs ? ownIPs, endpoint ? null, port ? 51821, persistentKeepalive ? 25, presharedKey ? null }: {
    inherit publicKey allowedIPs persistentKeepalive presharedKey;
    endpoint = if endpoint != null then
      "${endpoint}:${builtins.toString port}"
      else null;
  };

  foreignPeers = lib.filterAttrs (name: value: name != hostname) peers;
  foreignServerPeers = lib.filterAttrs (name: value: value.endpoint != null) foreignPeers;

  peerlist = if (peers.${hostname}.endpoint != null) then
    builtins.mapAttrs (name: mkPeer) foreignPeers
  else
    builtins.mapAttrs (name: mkPeer) foreignServerPeers;

  listenPort = peers.${hostname}.port or 51821;
in
{
  options.phil.wireguard = {
    enable = mkOption {
      description = "enable wireguard module";
      type = types.bool;
      default = true;
    };

    nat = mkOption {
      description = "enable nat for wireguard";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    sops.secrets = {
      wireguard-key = {
        sopsFile = ../../../sops/${hostname}-wireguard.yaml;
        #sopsFile = "../../../sops/${hostname}-wireguard.yaml";
      };
    };

    networking = {
      nat.enable = cfg.nat;
      hosts = (builtins.listToAttrs
        (builtins.concatLists
          (builtins.map
            (item: builtins.map (ip: {
              name = builtins.elemAt (builtins.split "/" ip) 0;
              value = [ "${item.name}.yggdrasil.vpn" ];
            }) item.ips)
            (lib.mapAttrsToList (name: value: {
              name = name;
              ips = value.ownIPs;
            }) peers)
          )
        )
      );
      firewall.allowedUDPPorts = [ listenPort ];
      wireguard = {
        enable = true;
        interfaces = {
          yggdrasil = {
            peers = (lib.mapAttrsToList (name: value: value) peerlist);
            ips = peers.${hostname}.ownIPs;
            inherit listenPort;
            privateKeyFile = config.sops.secrets.wireguard-key.path;
          };
        };
      };
    };
  };
}
