{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkDefault;
  networkName = "yggdrasil";
  postSetup = "${pkgs.inetutils}/bin/ifconfig ${networkName} mtu 1280 up";

  cfg = config.phil.wireguard;
  hostname = config.networking.hostName;

  #peers = import ./wireguard-peers.nix {inherit pkgs lib net;};
  peers = {};
  mkPeer = {
    publicKey,
    ownIPs,
    allowedIPs ? ownIPs,
    endpoint ? null,
    port ? 51821,
    persistentKeepalive ? 25,
    presharedKey ? null,
    ...
  }: {
    inherit publicKey allowedIPs persistentKeepalive presharedKey;
    endpoint =
      if endpoint != null
      then "${endpoint}:${builtins.toString port}"
      else null;
  };

  hasEndpoint = (peers.${hostname}.endpoint or null) != null;
  foreignPeers = lib.filterAttrs (name: _value: name != hostname) peers;
  foreignServerPeers = lib.filterAttrs (_name: value: (value.endpoint or null) != null) foreignPeers;

  # the vps knows all peers, the others only themselves + the vps => road-warrior setup
  peerlist =
    if hasEndpoint
    then builtins.mapAttrs (_name: mkPeer) foreignPeers
    else builtins.mapAttrs (_name: mkPeer) foreignServerPeers;

  listenPort = peers.${hostname}.port or 51821;
in {
  options.phil.wireguard = {
    enable = lib.mkEnableOption "wireguard module";
    domain = mkOption {
      description = "wireguard domain";
      type = types.str;
      default = "${networkName}.vpn";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      wireguard-key = {
        sopsFile = ../../../sops/machines + "/${hostname}.yaml";
      };
    };

    networking = {
      nat.enable = mkDefault hasEndpoint;
      hosts =
        builtins.listToAttrs
        (
          builtins.concatLists
          (
            builtins.map
            (item:
              builtins.map
              (ip: {
                name = builtins.elemAt (builtins.split "/" ip) 0;
                value = ["${item.name}.${cfg.domain}"];
              })
              item.ips)
            (lib.mapAttrsToList
              (name: value: {
                inherit name;
                ips = value.ownIPs;
              })
              peers)
          )
        );

      firewall.allowedUDPPorts = [listenPort];

      wireguard = {
        # broken currently after the network module rewrite
        enable = false;
        interfaces = {
          "${networkName}" = {
            inherit postSetup;
            peers = lib.mapAttrsToList (_name: value: value) peerlist;
            ips = peers.${hostname}.ownIPs;
            inherit listenPort;
            privateKeyFile = config.sops.secrets.wireguard-key.path;
          };
        };
      };
    };
  };
}
