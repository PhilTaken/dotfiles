{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    types
    mkEnableOption
    ;
  cfg = config.phil.fileshare;
  net = config.phil.network;

  mkSharesForIps =
    ips: shares:
    (
      "/export\t" + (lib.concatMapStrings (ip: "${ip}(rw,fsid=0,no_subtree_check,crossmnt,fsid=0) ") ips)
    )
    + "\n"
    + (lib.concatMapStrings (
      share:
      "/export${share}\t"
      + (lib.concatMapStrings (ip: "${ip}(rw,nohide,insecure,no_subtree_check) ") ips)
      + "\n"
    ) shares);

  mkMountsForBinds =
    binds:
    builtins.listToAttrs (
      builtins.concatLists (
        builtins.map (
          bind:
          builtins.map (bindcfg: {
            name = bindcfg.local;
            value =
              let
                ip = if bind.host == null then bind.ip else net.nodes.${bind.host}.network_ip."headscale";
              in
              {
                device = "${ip}:${bindcfg.remote}";
                fsType = "nfs4";
                # mount on first access instead of boot, unmount after 10 mins
                options = [
                  "x-systemd.automount"
                  "noauto"
                  "x-systemd.idle-timeout=600"
                ];
              };
          }) bind.dirs
        ) binds
      )
    );

  mkBindsForDirs =
    dirs:
    builtins.listToAttrs (
      builtins.map (dir: {
        name = "/export${dir}";
        value = {
          device = dir;
          options = [ "bind" ];
        };
      }) dirs
    );
in
{
  options.phil.fileshare = {
    mount = {
      enable = mkEnableOption "mounting shares";

      binds = mkOption {
        description = "list of binds";
        type = types.listOf (
          types.submodule {
            options = {
              ip = mkOption {
                description = "ip of the sharing server";
                type = types.nullOr types.str;
                default = null;
              };
              host = mkOption {
                description = "hostname of the sharing server";
                type = types.nullOr types.str;
                default = null;
              };
              dirs = mkOption {
                description = "shares to mount";
                type = types.listOf (
                  types.submodule {
                    options = {
                      local = mkOption { type = types.str; };
                      remote = mkOption { type = types.str; };
                    };
                  }
                );
                default = { };
              };
            };
          }
        );
        default = [ ];
      };
    };

    shares = {
      dirs = mkOption {
        description = "directories to share";
        type = types.listOf types.str;
        default = [ ];
      };

      ips = mkOption {
        description = "ips to share to";
        type = types.listOf types.str;
        default = lib.mapAttrsToList (_n: v: v.netmask) net.networks;
      };
    };
  };

  config =
    let
      enableMount = cfg.mount.binds != [ ];
      enableShare = cfg.shares.dirs != [ ];
    in
    mkIf (enableMount || enableShare) {
      services.nfs.server = {
        enable = enableShare;
        exports = mkSharesForIps cfg.shares.ips cfg.shares.dirs;
      };

      networking.firewall.allowedTCPPorts = [ ] ++ (if enableShare then [ 2049 ] else [ ]);

      fileSystems =
        (if enableMount then mkMountsForBinds cfg.mount.binds else { })
        // (if enableShare then mkBindsForDirs cfg.shares.dirs else { });
    };
}
