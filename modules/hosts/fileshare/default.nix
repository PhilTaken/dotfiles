{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.fileshare;
  wireguard = config.phil.wireguard;

  mkSharesForIps = ips: shares: "/export\t${ips}(insecure,rw,sync,no_subtree_check,crossmnt,fsid=0)\n" +
    (lib.concatMapStrings (share: "${share}\t${ips}(insecure,rw,sync,no_subtree_check)") shares);

  mkMountsForIp = ip: dirs: builtins.listToAttrs (builtins.map
    (dir: {
      name = "/mnt/${dir}";
      value = {
        device = "${ip}:${dir}";
        fstype = "nfs";
      };
    })
    dirs);

  mkBindsForDirs = dirs: builtins.listToAttrs (builtins.map
    (dir: {
      name = "/export${dir}";
      value = {
        device = dir;
        options = [ "bind" ];
      };
    })
    dirs);
in
{
  options.phil.fileshare = {
    enable = mkEnableOption "the fileshare module";

    mount = {
      enable = mkEnableOption "mounting shares";

      ip = mkOption {
        description = "ip of the sharing server";
        type = types.str;
      };

      dirs = mkOption {
        description = "shares to mount";
        type = types.nullOr types.listOf types.path;
        default = null;
      };
    };

    shares = {
      enable = mkEnableOption "nfs sharing";

      dirs = mkOption {
        description = "directories to share";
        type = types.nullOr types.listOf types.path;
        default = null;
      };

      ips = mkOption {
        description = "ips to share to";
        type = types.str;
        default = if wireguard.enable then "10.100.0.0/24" else "*";
      };
    };
  };

  config = mkIf (cfg.enable) {
    services.nfs.server = mkIf (cfg.shares.enable) {
      enable = true;
      exports = mkSharesForIps cfg.shares.ips cfg.shares.dirs;
    };

    networking.firewall.allowedTCPPorts = mkIf (cfg.shares.enable) [ 2049 ];

    fileSystems = (if (cfg.mount.enable) then
      mkMountsForIp cfg.mount.ip cfg.mount.dirs
    else { }) // (if (cfg.shares.enable) then
      mkBindsForDirs cfg.shares.dirs
    else { });
  };
}
