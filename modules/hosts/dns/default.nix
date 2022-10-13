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
  default_nameserver = builtins.head
    (builtins.attrNames
      (lib.filterAttrs
        (name: value: lib.hasInfix "unbound" (lib.concatStrings value))
        net.services));
  same-server = config.networking.hostName == cfg.nameserver;
in
{
  options.phil.dns = {
    enable = mkEnableOption "dns over tls";
    nameserver = mkOption {
      type = types.nullOr (types.enum hostnames);
      description = "dns host";
      example = "gamma";
      #default = null;
      default = default_nameserver;
    };
  };

  config = mkIf (cfg.nameserver != null) {
    #networking.networkmanager.dns = mkIf (config.networking.networkmanager.enable == true) "none";

    networking.nameservers =
      if same-server then [ "localhost" ] else [ "${iplot.${cfg.nameserver}}#dns.pherzog.xyz" ];

    services.resolved = {
      enable = ! same-server;

      fallbackDns = [ "2a0e:dc0:6:23::2#dot-ch.blahdns.com" ];

      extraConfig = ''
        DNSOverTLS=yes
      '';

      dnssec = "false";
    };
  };
}
