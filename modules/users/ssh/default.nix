{
  config,
  lib,
  pkgs,
  netlib,
  ...
}: let
  cfg = config.phil.ssh;
  inherit (lib) mkEnableOption mkIf;
in {
  options.phil.ssh = {
    enable = mkEnableOption "ssh";
  };

  config = mkIf cfg.enable {
    home.shellAliases = {
      s = "ssh $(cat ~/.ssh/known_hosts | cut -d ' ' -f 1 | sort | uniq | ${pkgs.skim}/bin/sk)";
    };

    programs.ssh = {
      enable = true;
      matchBlocks = let
        # every host has a headscale ip, right?
        headscale_hosts = lib.mapAttrs (_: v: v.network_ip."headscale") (lib.filterAttrs (_: v: v.network_ip ? "headscale") netlib.nodes);

        # add a suffix for the public ips
        public_hosts =
          lib.mapAttrs'
          (n: v: lib.nameValuePair (n + "-public") v.network_ip."public_ip")
          (lib.filterAttrs (_: v: v ? public_ip) netlib.nodes);
      in
        headscale_hosts // public_hosts;
    };
  };
}
