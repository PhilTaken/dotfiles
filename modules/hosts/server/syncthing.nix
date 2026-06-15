{
  config,
  lib,
  netlib,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    types
    mkEnableOption
    ;
  cfg = config.phil.server.services.syncthing;

  sopsConfig = {
    sopsFile = ../../../sops/machines + "/${config.networking.hostName}.yaml";
    owner = config.systemd.services."syncthing".serviceConfig.User or "syncthing";
  };
in
{
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

    port = mkOption {
      description = "syncthing port (webinterface)";
      type = types.port;
      default = netlib.portFor "syncthing";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.syncthing-cert = sopsConfig;
    sops.secrets.syncthing-key = sopsConfig;

    services.syncthing = {
      inherit (cfg)
        enable
        configDir
        dataDir
        ;

      guiAddress = "0.0.0.0:${builtins.toString cfg.port}";

      key = config.sops.secrets.syncthing-key.path;
      cert = config.sops.secrets.syncthing-cert.path;

      overrideFolders = cfg.override;
      overrideDevices = cfg.override;

      settings = {
        gui.theme = "black";
      };
    };

    phil.server.services = {
      caddy.proxy."syncthing" = {
        inherit (cfg) port;
        public = false;
        vhostConfig.extraConfig = ''
          client_max_body_size 2G;
        '';
      };
    };
  };
}
