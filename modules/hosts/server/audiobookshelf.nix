{
  config,
  lib,
  net,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.audiobookshelf;
in {
  options.phil.server.services.audiobookshelf = {
    enable = mkEnableOption "audiobookshelf";
    host = mkOption {
      description = "audiobookshelf domain";
      type = types.str;
      default = "audiobookshelf";
    };

    port = mkOption {
      type = types.port;
      default = 8088;
    };
  };

  config = mkIf cfg.enable {
    # open firewall
    networking.firewall.interfaces."${net.networks.default.interfaceName}" = {
      allowedUDPPorts = [cfg.port];
      allowedTCPPorts = [cfg.port];
    };

    # configure the proxy
    phil.server.services.caddy.proxy."${cfg.host}" = {inherit (cfg) port;};
    phil.homer.apps."${cfg.host}" = {
      show = true;
      settings = {
        name = "Audiobookshelf";
        subtitle = "Audiobooks";
        tag = "app";
        keywords = "selfhosted audiobooks";
        logo = "https://gitea.io/images/gitea.png";
      };
    };

    # configure the service itself
    services.audiobookshelf = {
      enable = true;
      host = "0.0.0.0";
      inherit (cfg) port;
    };
  };
}
