{ pkgs, ... }:
{
  imports = [ ./configuration.nix ];

  phil.server.services.telegraf.inputs.extrasensors = false;
  phil.fileshare.shares.dirs = [ "/media" ];

  phil.backup.enable = true;

  phil.backup.jobs = {
    "syncthing" = "/media/syncthing";
    "music" = "/media/Music";
  };

  phil.backup.repo = "/media_int/backups";
}
