{ pkgs, ... }:
{
  imports = [ ./configuration.nix ];

  virtualisation.docker.enable = true;

  phil.fileshare.shares.dirs = [ "/media" ];
  phil.backup.enable = true;

  phil.backup.repo = "/media/backups";

  environment.systemPackages = [
    pkgs.beets
  ];

  #nixpkgs.config.packageOverrides = pkgs: {
  #vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  #};
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      #vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

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
