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
  };

  config = mkIf (cfg.enable) {
    services.seafile = {
      enable = true;
      seafilePackage = pkgs.seafile-server.overrideAttrs (old: {
        version = "git";
        src = pkgs.fetchFromGitHub {
          owner = "haiwen";
          repo = "seafile-server";
          rev = "881c270aa8d99ca6648e7aa1458fc283f38e6f31";
          sha256 = "sha256-M1jIysirtl1KKyEvScOIshLvSa5vjxTdFEARgy8bLTc=";
        };
      });
      adminEmail = "john@example.com";
      initialAdminPassword = "test123";
      ccnetSettings.General.SERVICE_URL = "seafile.home:8084";
    };
  };
}
