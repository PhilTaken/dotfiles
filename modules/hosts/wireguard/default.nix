{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.wirgeguard-server;
  hostname = config.networking.hostName;

  peers = import ./wireguard-peers.nix;
  mkPeer = { publicKey, address, allowedIPs ? address, endpoint ? null, port ? 51820, persistentKeepalive ? null, presharedKey ? null }: {
    inherit publicKey allowedIPs persistentKeepalive presharedKey;
    endpoint = if endpoint != null then
      "${endpoint}:${builtins.toString port}"
      else null;
  };
in
{
  options.phil.wirgeguard-server = {
    enable = mkOption {
      description = "enable wirgeguard-server module";
      type = types.bool;
      default = false;
    };

    isServer = mkOption {
      description = "wether the peer should act like a server";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    sops.secrets = {
      wireguard-key = {
        sopsFile = builtins.toPath "../sops/${hostname}-wireguard.yaml";
      };
    };

    networking = mkIf (cfg.isServer) {
      nat = {
        enable = true;
        externalInterface = "eth0";
        internalInterfaces = [ "wg0" ];
      };

      firewall = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 listenPort ];
      };
    };

    networking.wg-quick.interfaces.wg0 = (if (cfg.isServer) then let
      ipv4 = builtins.head peers.server.ownIPs;
      ipv6 = builtins.head (builtins.tail peers.server.ownIPs);
      clientPeers = builtins.mapAttrs (name: mkPeer) peers.clients;
    in {
      inherit listenPort;

      postUp = ''
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${ipv4} -o eth0 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -A POSTROUTING -s ${ipv6} -o eth0 -j MASQUERADE
      '';

      preDown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${ipv4} -o eth0 -j MASQUERADE
        ${pkgs.iptables}/bin/ip6tables -D FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -t nat -D POSTROUTING -s ${ipv6} -o eth0 -j MASQUERADE
      '';

      peers = clientPeers;
    } else {
      dns = peers.server.ownIPs;
      peers = mkPeer peers.server;
    }) // {
      address = peers.${hostname}.address;
      privateKeyFile = config.sops.secrets.wireguard-key.path;
    };
  };
}
