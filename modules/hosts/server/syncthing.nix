{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.syncthing;

  sopsConfig = {
    sopsFile = ../../../sops/machines + "/${config.networking.hostName}.yaml";
    owner = config.systemd.services."syncthing".serviceConfig.User or "syncthing";
  };
in {
  options.phil.server.services.syncthing = {
    enable = mkEnableOption "syncthing service";
    baseDir = mkOption {
      description = "syncthing base dir";
      type = types.str;
      default = "/media/syncthing";
    };

    dataDir = mkOption {
      description = "folder for synced folders";
      type = types.str;
      default = "${cfg.baseDir}/data";
    };
    configDir = mkOption {
      description = "folder for syncthing config";
      type = types.str;
      default = "${cfg.baseDir}/config";
    };

    override = mkEnableOption "override folders and devices";

    openDefaultPorts = mkEnableOption "open default ports";
  };

  config = mkIf cfg.enable {
    sops.secrets.syncthing-cert = sopsConfig;
    sops.secrets.syncthing-key = sopsConfig;

    phil.backup.jobs."syncthing" = {
      paths = [cfg.baseDir];
    };

    services.syncthing = {
      inherit (cfg) openDefaultPorts enable configDir dataDir;

      guiAddress = "0.0.0.0:8384";

      key = config.sops.secrets.syncthing-key.path;
      cert = config.sops.secrets.syncthing-cert.path;

      #devices = {
      #};

      #folders = {
      #"" = {
      #};
      #};

      overrideFolders = cfg.override;
      overrideDevices = cfg.override;

      settings = {
        gui.theme = "black";
      };
    };
  };
}
