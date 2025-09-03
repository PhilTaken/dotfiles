{
  config,
  lib,
  netlib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkIf
    types
    mkEnableOption
    ;
  cfg = config.phil.server.services.vikunja;
in
{
  options.phil.server.services.vikunja = {
    enable = mkEnableOption "vikunja";
    url = mkOption {
      description = "vikunja url (webinterface)";
      default = "https://${cfg.hostname}";
      type = types.str;
    };
    port = mkOption {
      description = "port for the http interface";
      type = types.port;
      default = netlib.portFor "vikunja";
    };
    host = mkOption {
      type = types.str;
      default = "vikunja";
    };
    hostname = mkOption {
      type = types.str;
      default = netlib.domainFor cfg.host;
    };
  };

  config = mkIf cfg.enable {
    services.vikunja = {
      inherit (cfg) enable;

      port = cfg.port;
      frontendScheme = "https";
      frontendHostname = cfg.hostname;
      database.type = "sqlite";

      environmentFiles = [ config.sops.secrets.vikunja-environmentfile.path ];

      settings = {
        service.publicurl = cfg.url;
        auth.openid = {

          # TODO re-enable after the next update that enables setting secret values via environment value / file
          enabled = false;
          providers.keycloak = {
            name = "keycloak";
            authurl = "https://keycloak.pherzog.xyz/realms/services";
            logouturl = "https://keycloak.pherzog.xyz/realms/services/protocol/openid-connect/logout";
          };
        };
      };
    };

    sops.secrets.vikunja-environmentfile.mode = "777";

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {
        inherit (cfg) port;
        public = false;
      };

      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Vikunja";
          subtitle = "TODO + project manager";
          tag = "app";
          keywords = "selfhosted todo projects";
          logo = "";
        };
      };
    };
  };
}
