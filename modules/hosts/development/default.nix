{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.phil.development;
in
{
  options.phil.development = {
    enable = mkEnableOption "dev";
  };

  config = mkIf cfg.enable {
    programs = {
      #adb.enable = true;
    };

    environment.systemPackages = with pkgs; [
      android-tools
    ];
  };
}
