{...}: {
  imports = [./configuration.nix];

  virtualisation.docker.enable = true;

  phil.fileshare.shares.dirs = ["/media"];
  phil.backup.enable = true;

  phil.backup.repo = "/media_int/backups";
}
