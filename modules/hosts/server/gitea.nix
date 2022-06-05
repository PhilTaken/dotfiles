{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.gitea;
in
{

  options.phil.server.services.gitea = {
    enable = mkEnableOption "gitea";
    url = mkOption {
      description = "gitea url (webinterface)";
      default = "https://gitea.home";
      type = types.str;
    };
    port = mkOption {
      description = "port for the http interface";
      type = types.port;
      default = 3000;
    };
    stateDir = mkOption {
      description = "state dir for gitea";
      type = types.str;
      default = "/media/gitea";
    };
  };

  config = mkIf (cfg.enable) {
    services.gitea = {
      inherit (cfg) stateDir enable;

      domain = "gitea.home";
      rootUrl = "https://gitea.home/";
      #httpAddress = "http://gitea.home/";

      httpPort = cfg.port;
      ssh.enable = true;
      lfs.enable = true;
      cookieSecure = true;
      appName = "Oroboros";
    };

    phil.server.services.caddy.proxy."gitea" = cfg.port;
  };
}
