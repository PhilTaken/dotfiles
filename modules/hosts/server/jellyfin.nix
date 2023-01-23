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
    host = mkOption {
      type = types.str;
      default = "jellyfin";
    };
    port = mkOption {
      type = types.port;
      default = 8096;
    };
  };

  config = mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    phil.server.services.caddy.proxy."${cfg.host}" = { inherit (cfg) port; };
  };
}
