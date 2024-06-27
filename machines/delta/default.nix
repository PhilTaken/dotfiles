{pkgs, ...}: {
  imports = [./configuration.nix];

  virtualisation.docker.enable = true;

  phil.fileshare.shares.dirs = ["/media"];
  phil.backup.enable = true;

  phil.backup.repo = "/media_int/backups";

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
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}
