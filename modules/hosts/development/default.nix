{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.development;
in
{
  options.phil.development = {
    enable = mkOption {
      description = "enable development module";
      type = types.bool;
      default = false;
    };

    adb.enable = mkEnableOption "android adb";
  };

  config = mkIf cfg.enable {
    programs = {
      adb.enable = cfg.adb.enable;
    };
  };
}

