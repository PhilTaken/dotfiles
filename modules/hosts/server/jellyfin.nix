{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.jellyfin;
in {
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
    # TODO ensure the arrs are enabled aswell
    services.jellyfin = {
      enable = true;
      group = "media";
      openFirewall = true;
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {inherit (cfg) port;};
      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Jellyfin";
          subtitle = "Multi-Media Platform";
          tag = "app";
          keywords = "selfhosted movies series";
          logo = "https://jellyfin.org/images/logo.svg";
        };
      };
    };
  };
}
