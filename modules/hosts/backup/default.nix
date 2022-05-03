{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.backup;
in
{
  options.phil.backup = {
    enable = mkOption {
      description = "enable backup module";
      type = types.bool;
      default = false;
    };

    folders = mkOption {
      description = "folders to backup";
      type = types.listOf types.str;
      default = [ ];
    };

    # more options
  };

  config = mkIf (cfg.enable) {
    services.borgbackup = {
      #enable = cfg.enable;

    };
    # add config here
  };
}
