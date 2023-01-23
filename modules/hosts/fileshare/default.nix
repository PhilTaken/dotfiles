{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.fileshare;
  inherit (config.phil) wireguard;
  inherit (config.phil) nebula;

  mkSharesForIps = ips: shares:
    ("/export\t" + (lib.concatMapStrings (ip: "${ip}(rw,fsid=0,no_subtree_check,crossmnt,fsid=0) ") ips)) + "\n" +
    (lib.concatMapStrings (share: "/export${share}\t" + (lib.concatMapStrings (ip: "${ip}(rw,nohide,insecure,no_subtree_check) ") ips) + "\n") shares);

  net = import ../../../network.nix { };
  iplot = net.networks.default;

  mkMountsForBinds = binds: builtins.listToAttrs (builtins.concatLists (builtins.map
    (bind: builtins.map
      (bindcfg: {
        name = bindcfg.local;
        value =
          let
            ip = if bind.host == null then bind.ip else net.networks.default.${bind.host};
          in
          {
            device = "${ip}:${bindcfg.remote}";
            fsType = "nfs4";
            # mount on first access instead of boot, unmount after 10 mins
            options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
          };
      })
      bind.dirs)
    binds));


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
        "public" = "yes";
        "force user" = "share";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    })
    dirs);
in
{
  options.phil.fileshare = {
    mount = {
      enable = mkEnableOption "mounting shares";

      binds = mkOption {
        description = "list of binds";
        type = types.listOf (types.submodule {
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
              type = types.listOf (types.submodule { options = {
                local = mkOption { type = types.str; };
                remote = mkOption { type = types.str; };
              }; });
              default = { };
            };
          };
        });
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
        default = [ "192.168.0.0/24" ] ++
          (if wireguard.enable then [ "10.100.0.0/24" ] else [ ]) ++
          (if nebula.enable then [ "10.200.0.0/24" ] else [ ]);
      };
    };

    samba = {
      dirs = mkOption {
        description = "directories to share";
        type = types.listOf types.str;
        default = [ ];
      };

      ips = mkOption {
        description = "ips to share to";
        type = types.str;
        default = if wireguard.enable then "10.100.0.0/24" else "*";
      };
    };
  };

  config =
    let
      enableSamba = cfg.samba.dirs != [ ];
      enableMount = cfg.mount.binds != [ ];
      enableShare = cfg.shares.dirs != [ ];
    in
    mkIf (enableSamba || enableMount || enableShare) {
      services.nfs.server = {
        enable = enableShare;
        exports = mkSharesForIps cfg.shares.ips cfg.shares.dirs;
      };

      services.samba-wsdd.enable = enableSamba;
      services.samba = {
        enable = enableSamba;
        securityType = "user";
        extraConfig = ''
          workgroup = WORKGROUP
          server string = Samba Server
          server role = standalone server
          log file = /var/log/samba/smbd.%m
          max log size = 50
          dns proxy = no
          map to guest = Bad User
          browseable = yes
        '';
        shares = mkSmbShares cfg.samba.dirs;
      };

      networking.firewall.allowedTCPPorts = [ ] ++
        (if enableShare then [ 2049 ] else [ ]) ++
        (if enableSamba then [ 445 139 ] else [ ]);

      networking.firewall.allowedUDPPorts = [ ] ++
        (if enableSamba then [ 137 138 ] else [ ]);

      fileSystems = (if enableMount then
        mkMountsForBinds cfg.mount.binds
      else { }) // (if enableShare then
        mkBindsForDirs cfg.shares.dirs
      else { });
    };
}
