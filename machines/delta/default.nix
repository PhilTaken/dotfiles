{
  imports = [
    ./hardware-configuration.nix
  ];

  virtualisation.docker.enable = true;

  # ----------------------------------------------------

  # TODO reenable when twisted is fixed
  # or rewrite it in a sane language ...
  phil.server.services.promexp.extrasensors = false;

  phil.fileshare = {
    nfs.shares.dirs = [ "/media" ];

    samba = {
      enable = true;
      share_dir = "/media/mount/tl/sims";
    };

    garage = {
      enable = true;
      data_dir = "/media/garage";
    };

    juicefs.server = {
      enable = true;
      bucket = "juicefs-data";
    };
  };

  # ----------------------------------------------------

  networking.hostId = "ef45f308";
  system.stateVersion = "22.05";
}
