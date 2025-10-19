{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  cfg = config.phil.ssh;
  inherit (lib) mkEnableOption mkIf;
  inherit (osConfig.phil) network;
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
        headscale_hosts =
          lib.mapAttrs (_: v: {
            hostname = v.network_ip."headscale";
            user = v.sshUser;
          })
          network.nodes;

        # add a suffix for the public ips
        public_hosts = lib.mapAttrs' (
          n: v:
            lib.nameValuePair (n + "-public") {
              hostname = v.public_ip;
              user = v.sshUser;
            }
        ) (lib.filterAttrs (_: v: !builtins.isNull v.public_ip) network.nodes);
      in
        headscale_hosts // public_hosts;
    };
  };
}
