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
  mkPeer = { publicKey, address, allowedIPs ? address, endpoint ? null, port ? 51820, persistentKeepalive ? null, presharedKey ? null }: {
    inherit publicKey allowedIPs persistentKeepalive presharedKey;
    endpoint = if endpoint != null then
      "${endpoint}:${builtins.toString port}"
      else null;
  };

  peerlist = builtins.mapAttrs (name: mkPeer) ((lib.filterAttrs (name: value: name != hostname) peers));
  listenPort = peers.${hostname}.port or 51820;
in
{
  options.phil.wireguard = {
    enable = mkOption {
      description = "enable wireguard module";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {
    sops.secrets = {
      wireguard-key = {
        sopsFile = builtins.toPath "../sops/${hostname}-wireguard.yaml";
      };
    };

    # IPv6 configuration
    # Prefix: fd2e:6bab:862b::/48
    # Subnets:
    # 1) Server machines
    #    1. primrose
    # 2) Humans
    #    1. longiflorum
    #    2. poco-m3 (my phone)
    #
    # Inside of the machine subnets there's a /72 prefix to allow
    # for a machine to claim multiple IP addresses - this is useful
    # for hosting containers, VMs and everything that requires a
    # whole IP address to itself without messing with port forwarding
    networking = {
      hosts = (builtins.listToAttrs
        (builtins.concatLists
          (builtins.map
            (item: builtins.map (ip: {
              name = builtins.elemAt (builtins.split "/" ip) 0;
              value = item.name + ".yggdrasil.vpn";
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
            peers = peerlist;
            ips = peers.${hostname}.ownIPs;
            inherit listenPort;
            privateKeyFile = config.sops.secrets.wireguard-key.path;
          };
        };
      };
    };
  };
}
