{
  pkgs,
  netlib,
  lib,
  config,
  ...
}:
{
  imports = [ ./configuration.nix ];
}
// lib.mkMerge [
  {
    virtualisation.docker.enable = true;

    phil.fileshare.nfs.shares.dirs = [ "/media" ];
    phil.backup.enable = true;

    phil.backup.repo = "/media/backups";

    environment.systemPackages = [
      pkgs.beets
    ];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        #vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
  }
  {
    # TODO move to fileshare?
    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          # see https://calomel.org/samba.html
          "workgroup" = "WORKGROUP";
          #"deadtime" = "15";
          "server string" = "smbnix";
          "netbios name" = "smbnix";
          "default case" = "lower";
          "preserve case" = "no";
          "security" = "user";
          "use sendfile" = "yes";
          # localhost is the ipv6 localhost ::1
          "guest account" = "nobody";
          "map to guest" = "bad user";
          "strict syn" = "no";
          "sync always" = "no";
          "syslog" = "1";
          "syslog only" = "yes";
          "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=65536 SO_SNDBUF=65536";
          "write cache size" = "524288";
          "getwd cache" = "yes";
          "min receivefile size" = "16384";
        };
        "public" = {
          "path" = "/media/mount/tl/sims";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0755";
          "directory mask" = "0755";
          "force user" = "nobody";
          "force group" = "nogroup";
        };
      };
    };

    services.samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  }

  # garage
  (
    let
      rpc_port = netlib.portFor "garage-rpc";
      s3_port = netlib.portFor "garage-s3";
      s3_web_port = netlib.portFor "garage-s3-web";
      k2v_port = netlib.portFor "garage-k2v";
      admin_port = netlib.portFor "garage-admin";

      s3_domain = netlib.domainFor ".s3.garage";
      s3_web_domain = netlib.domainFor ".web.garage";
    in
    {
      sops.secrets.garage-environmentfile = { };

      services.garage = {
        enable = true;
        package = pkgs.garage_2;
        environmentFile = config.sops.secrets.garage-environmentfile.path;
        settings = {
          data_dir = [
            {
              capacity = "2T";
              path = "/media/garage";
            }
          ];

          metadata_dir = "/var/lib/garage/meta";

          db_engine = "sqlite";

          replication_factor = 1;

          rpc_bind_addr = "[::]:${builtins.toString rpc_port}";
          rpc_public_addr = "127.0.0.1:${builtins.toString rpc_port}";

          k2v_api.api_bind_addr = "[::]:${builtins.toString k2v_port}";
          admin.api_bind_addr = "[::]:${builtins.toString admin_port}";

          s3_api = {
            s3_region = "garage";
            api_bind_addr = "[::]:${builtins.toString s3_port}";
            root_domain = s3_domain;
          };

          s3_web = {
            bind_addr = "[::]:${builtins.toString s3_web_port}";
            root_domain = s3_web_domain;
            index = "index.html";
          };
        };
      };

      phil.server.services.caddy.proxy = {
        "rpc.garage".port = rpc_port;
        "*.s3".port = s3_port;
        "*.s3web".port = s3_web_port;
      };
    }
  )
]
