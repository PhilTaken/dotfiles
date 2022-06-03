{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.seafile;
in
{

  options.phil.server.services.seafile = {
    enable = mkEnableOption "seafile";
    datadir = mkOption {
      type = types.str;
      default = "/var/lib/seafile";
    };
    hostName = mkOption {
      type = types.str;
      default = "seafile.home";
    };
  };

  config = mkIf (cfg.enable) {
    services.seafile = {
      enable = true;
      adminEmail = "john@example.com";
      initialAdminPassword = "test123";
      ccnetSettings.General.SERVICE_URL = "seafile.home:8084";
    };
  };
}
