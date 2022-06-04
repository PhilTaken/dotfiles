{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.dns;

  net = import ../../../network.nix {};
  iplot = net.networks.default;
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
