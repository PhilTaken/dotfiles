{
  config,
  lib,
  ...
}:
let
  cfg = config.phil.fileshare.samba;
in
{
  options.phil.fileshare.samba = {
    enable = lib.mkEnableOption "samba";

    share_dir = lib.mkOption {
      description = "public path for the samba share";
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
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
          "path" = cfg.share_dir;
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
  };
}
