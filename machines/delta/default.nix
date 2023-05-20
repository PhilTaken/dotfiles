{ ... }:
{
  imports = [ ./configuration.nix ];

  phil.fileshare.shares.dirs = [ "/media" ];
  phil.backup.enable = true;

  phil.backup.jobs = {
    "syncthing" = "/media/syncthing";
    "music" = "/media/Music";
    "nextcloud" = "/media/nextcloud";
  };

  phil.backup.repo = "/media_int/backups";
}
