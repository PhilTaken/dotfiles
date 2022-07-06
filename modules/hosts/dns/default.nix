{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.dns;

  net = import ../../../network.nix { };
  iplot = net.networks.default;
  hostnames = builtins.attrNames iplot;
in
{
  options.phil.dns = {
    enable = mkEnableOption "dns over tls";
    nameserver = mkOption {
      type = types.nullOr (types.enum hostnames);
      description = "dns host";
      example = "gamma";
      default = null;
    };
  };

  config = mkIf (cfg.nameserver != null) {
    #networking.networkmanager.dns = mkIf (config.networking.networkmanager.enable == true) "none";

    networking.nameservers = [
      "${iplot.${cfg.nameserver}}#dns.pherzog.xyz"
      #"1.1.1.1"
    ];

    services.resolved = {
      enable = true;

      fallbackDns = [
        "2a0e:dc0:6:23::2#dot-ch.blahdns.com"
      ];

      extraConfig = ''
        DNSOverTLS=yes
      '';

      dnssec = "false";
    };
  };
}
