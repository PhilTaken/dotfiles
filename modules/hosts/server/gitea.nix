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
      default = "https://gitea.pherzog.xyz";
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
    host = mkOption {
      type = types.str;
      default = "gitea";
    };
  };

  config = mkIf (cfg.enable) {
    services.gitea = {
      inherit (cfg) stateDir enable;

      domain = "${cfg.host}.pherzog.xyz";
      rootUrl = "https://${cfg.host}.pherzog.xyz/";

      httpPort = cfg.port;
      ssh.enable = true;
      lfs.enable = true;
      cookieSecure = true;
      appName = "Oroboros";
    };

    phil.server.services.caddy.proxy."gitea" = cfg.port;
  };
}
