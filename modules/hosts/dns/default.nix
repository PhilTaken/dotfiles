{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.dns;
  net = config.phil.network;
  hostnames = builtins.attrNames net.nodes;

  # TODO ensure at least one node is running unbound
  default_nameserver =
    builtins.head
    (builtins.attrNames
      (lib.filterAttrs
        (_name: nodeconfig: lib.elem "unbound" nodeconfig.services)
        net.nodes));

  same-server = config.phil.server.services.unbound.enable;
in {
  options.phil.dns = {
    enable = mkEnableOption "dns over tls";
    nameserver = mkOption {
      type = types.nullOr (types.enum hostnames);
      description = "dns host";
      example = "gamma";
      #default = default_nameserver;
      default = null;
    };
  };

  config = lib.mkMerge [
    # use public nameserver when not connected to nebula
    (mkIf (!config.phil.nebula.enable || cfg.nameserver == null) {
      networking.nameservers = ["9.9.9.9"];

      services.resolved = {
        enable = true;
        dnsovertls = "opportunistic";
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
          # https://github.com/systemd/systemd/issues/5755
          "${net.nodes.${cfg.nameserver}.network_ip."milkyway"}#dns.${net.tld}"
        ];

      services.resolved = {
        enable = ! same-server;
        dnsovertls = "opportunistic";
        dnssec = "false";
      };
    })
  ];
}
