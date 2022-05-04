{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.calibre;
in
{

  options.phil.server.services.calibre = {
    enable = mkEnableOption "calibre books web server";
  };

  config = mkIf (cfg.enable) {
    services.calibre-web = {
      enable = true;
      listen.port = 8083;
      options = {
        enableBookUploading = true;
      };
      openFirewall = true;
    };
  };
}
