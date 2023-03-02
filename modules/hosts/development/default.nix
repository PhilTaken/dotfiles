{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.development;
in
{
  options.phil.development = {
    enable = mkEnableOption "dev";
    adb.enable = mkEnableOption "android adb";
  };

  config = mkIf cfg.enable {
    programs = {
      adb.enable = cfg.adb.enable;
    };

    environment.systemPackages = with pkgs; [
      android-tools
    ];
  };
}

