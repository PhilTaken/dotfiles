{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.dns;

  wgpeers = import ../wireguard/wireguard-peers.nix { inherit pkgs; };
  iplot = builtins.mapAttrs (name: value: builtins.elemAt (builtins.split "/" (lib.head value.ownIPs)) 0) wgpeers;
  hostnames = builtins.attrNames iplot;
in
{
  options.phil.dns = {
    nameserver = mkOption {
      type = types.nullOr (types.enum hostnames);
      description = "dns host";
      example = "gamma";
      default = null;
    };
  };

  config = mkIf (cfg.nameserver != null) {
    networking.nameservers = [ iplot."${cfg.nameserver}" "1.1.1.1" ];
    networking.networkmanager.dns = mkIf (config.networking.networkmanager.enable == true) "none";
  };
}
