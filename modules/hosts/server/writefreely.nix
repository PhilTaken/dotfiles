{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.writefreely;
  net = config.phil.network;
in {
  options.phil.server.services.writefreely = {
    enable = mkEnableOption "writefreely";
    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/writefreely";
    };

    host = mkOption {
      type = types.str;
      default = "blog";
    };

    port = mkOption {
      type = types.port;
      default = 18080;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.writefreely-adminpass = {
      inherit (config.services.writefreely) group;
    };

    services.writefreely = {
      inherit (cfg) enable stateDir;

      settings.server = {
        inherit (cfg) port;
      };

      nginx.enable = false;
      host = "${cfg.host}.${net.tld}";

      admin = {
        name = "pherzog";
        initialPasswordFile = config.sops.secrets.writefreely-adminpass.path;
      };
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {
        inherit (cfg) port;
        #public = true;
      };

      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Writefreely";
          subtitle = "Blogging platform";
          tag = "app";
          keywords = "selfhosted blog";
          logo = "https://writefreely.org/img/icon.svg";
        };
      };
    };
  };
}
