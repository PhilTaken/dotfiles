{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.syncthing;
in
{

  options.phil.server.services.syncthing = {
    enable = mkEnableOption "syncthing service";
    dataFolder = mkOption {
      description = "folder for synced folders";
      type = types.str;
      default = "/media/syncthing/data";
    };
    configFolder = mkOption {
      description = "folder for syncthing config";
      type = types.str;
      default = "/media/syncthing/config";
    };
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = "nixos";
      dataDir = cfg.dataFolder;
      configDir = cfg.configFolder;
      openDefaultPorts = true;
      guiAddress = "0.0.0.0:8384";
    };
  };
}
