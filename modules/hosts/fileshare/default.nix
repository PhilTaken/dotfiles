{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.fileshare;
  wireguard = config.phil.wireguard;

  mkSharesForIps = ips: shares:
    ("/export\t" + (lib.concatMapStrings (ip: "${ip}(rw,fsid=0,no_subtree_check,crossmnt,fsid=0) ") ips)) + "\n" +
    (lib.concatMapStrings (share: "/export${share}\t" + (lib.concatMapStrings (ip: "${ip}(rw,nohide,insecure,no_subtree_check) ") ips) + "\n") shares);

  mkMountsForBinds = binds: builtins.listToAttrs (builtins.concatLists (
    (builtins.map
      (bind: builtins.map
        (dir: {
          name = "/mnt${dir}";
          value = {
            device = "${bind.ip}:${dir}";
            fsType = "nfs4";
            # mount on first access instead of boot, unmount after 10 mins
            options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
          };
        })
        bind.dirs)
      binds)
  ));


  mkBindsForDirs = dirs: builtins.listToAttrs (builtins.map
    (dir: {
      name = "/export${dir}";
      value = {
        device = dir;
        options = [ "bind" ];
      };
    })
    dirs);

  mkSmbShares = dirs: builtins.listToAttrs (builtins.map
    (dir: {
      name = builtins.baseNameOf dir;
      value = {
        path = dir;
        browsable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    })
    dirs);
in
{
  options.phil.fileshare = {
    enable = mkEnableOption "the fileshare module";

    mount = {
      enable = mkEnableOption "mounting shares";

      binds = mkOption {
        description = "list of binds";
        type = types.listOf (types.submodule {
          options = {
            ip = mkOption {
              description = "ip of the sharing server";
              type = types.str;
            };
            dirs = mkOption {
              description = "shares to mount";
              type = types.listOf types.str;
              default = [ ];
            };
          };
        });
        default = [ ];
      };
    };

    shares = {
      enable = mkEnableOption "nfs sharing";

      dirs = mkOption {
        description = "directories to share";
        type = types.nullOr (types.listOf types.str);
        default = null;
      };

      ips = mkOption {
        description = "ips to share to";
        type = types.listOf types.str;
        default = [ (if wireguard.enable then "10.100.0.0/24" else "*") "192.168.8.0/24" ];
      };
    };

    samba = {
      enable = mkEnableOption "samba sharing";

      dirs = mkOption {
        description = "directories to share";
        type = types.nullOr (types.listOf types.str);
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

    services.samba = mkIf (cfg.samba.enable) {
      enable = true;
      securityType = "user";
      extraConfig = ''
        workgroup = WORKGROUP
        server string = smbnix
        netbios name = smbnix
        security = user
        #use sendfile = yes
        #max protocol = smb2
        hosts allow = ${cfg.samba.ips} localhost 192.168.8.0/24
        hosts deny = 0.0.0.0/0
        guest account = nobody
        map to guest = bad user
      '';
      shares = mkSmbShares cfg.samba.dirs;
    };

    networking.firewall.allowedTCPPorts = [ ] ++
      (if (cfg.shares.enable) then [ 2049 ] else [ ]) ++
      (if (cfg.samba.enable) then [ 445 139 ] else [ ]);

    networking.firewall.allowedUDPPorts = [ ] ++
      (if (cfg.samba.enable) then [ 137 138 ] else [ ]);

    fileSystems = (if (cfg.mount.enable) then
      mkMountsForBinds cfg.mount.binds
    else { }) // (if (cfg.shares.enable) then
      mkBindsForDirs cfg.shares.dirs
    else { });
  };
}
