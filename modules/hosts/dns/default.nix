{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.dns;

  wgpeers = import ../wireguard/wireguard-peers.nix;
  iplot = builtins.mapAttrs (name: value: builtins.elemAt (builtins.split "/" (lib.head value.ownIPs)) 0) wgpeers;
  hostnames = builtins.attrNames iplot;
in
{
  imports = [
    ./server.nix
    ./apps.nix
  ];

  options.phil.dns = {
    nameserver = mkOption {
      type = types.nullOr (types.enum hostnames);
      description = "dns host";
      example = "gamma";
      default = null;
    };
  };

  config = mkIf (cfg.nameserver != null) {
    networking.nameservers = mkDefault [ iplot."${cfg.nameserver}" ];
    networking.networkmanager.dns = "none";
  };
}
