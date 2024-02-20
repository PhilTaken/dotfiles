{
  config,
  lib,
  net,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.dns;

  iplot = net.networks.default.hosts;
  hostnames = builtins.attrNames iplot;
  default_nameserver =
    builtins.head
    (builtins.attrNames
      (lib.filterAttrs
        (_name: value: lib.hasInfix "unbound" (lib.concatStrings value))
        net.services));
  same-server = config.phil.server.services.unbound.enable;
in {
  options.phil.dns = {
    enable = mkEnableOption "dns over tls";
    nameserver = mkOption {
      type = types.nullOr (types.enum hostnames);
      description = "dns host";
      example = "gamma";
      default = default_nameserver;
    };
  };

  config = lib.mkMerge [
    # use public nameserver when not connected to nebula
    (mkIf (!config.phil.nebula.enable) {
      networking.nameservers = ["9.9.9.9"];

      services.resolved = {
        enable = true;

        fallbackDns = ["1.1.1.1"];

        extraConfig = ''
          DNSOverTLS=yes
        '';

        dnssec = "false";
      };
    })

    # otherwise just use the one on the nebula network
    (mkIf (cfg.nameserver != null && config.phil.nebula.enable) {
      #networking.networkmanager.dns = mkIf (config.networking.networkmanager.enable == true) "none";

      networking.nameservers =
        if same-server
        then ["localhost"]
        else [
          "${iplot.${cfg.nameserver}}#dns.${net.tld}"
          "2a0e:dc0:6:23::2#dot-ch.blahdns.com"
        ];

      services.resolved = {
        enable = ! same-server;

        fallbackDns = ["2a0e:dc0:6:23::2#dot-ch.blahdns.com"];

        extraConfig = ''
          DNSOverTLS=yes
        '';

        dnssec = "false";
      };
    })
  ];
}
