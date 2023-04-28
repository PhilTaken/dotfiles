{ pkgs, ... }:
{
  imports = [ ./configuration.nix ];

  phil.fileshare.shares.dirs = [ "/media" ];
  phil.backup.enable = true;

  phil.backup.jobs = {
    "syncthing" = "/media/syncthing";
    "music" = "/media/Music";
  };

  phil.backup.repo = "/media_int/backups";
}
