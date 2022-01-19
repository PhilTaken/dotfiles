{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.jellyfin;
in
{

  options.phil.server.services.jellyfin = {
    enable = mkEnableOption "jellyfin media server";
  };

  config = mkIf (cfg.enable) {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
}
