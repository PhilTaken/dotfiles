{
  config,
  lib,
  netlib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  cfg = config.phil.server.services.kanidm;
  net = config.phil.network;
in
{
  options.phil.server.services.kanidm = {
    enable = mkEnableOption "kanidm";

    port = mkOption {
      type = types.port;
      default = netlib.portFor "kanidm";
    };

    host = mkOption {
      type = types.str;
      default = "kanidm";
    };
  };

  config = mkIf cfg.enable {
    services.kanidm = {
      enableServer = cfg.enable;
      enableClient = cfg.enable;

      package = pkgs.kanidm_1_7;

      clientSettings = {
        uri = config.services.kanidm.serverSettings.origin;
      };

      serverSettings = rec {
        domain = netlib.domainFor "kanidm";
        origin = "https://${domain}";

        bindaddress = "0.0.0.0:${builtins.toString cfg.port}";
        ldapbindaddress = "0.0.0.0:636";

        tls_chain = "${config.security.acme.certs."${net.tld}".directory}/fullchain.pem";
        tls_key = "${config.security.acme.certs."${net.tld}".directory}/key.pem";
      };
    };

    users.users.kanidm.extraGroups = [ "nginx" ];

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {
        inherit (cfg) port;
        public = false;
        proxyPass = "https://127.0.0.1:${builtins.toString cfg.port}";
      };
      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Kanidm";
          subtitle = "Authentication";
          tag = "app";
          keywords = "selfhosted identity managment + ldap";
          logo = "https://pbs.twimg.com/profile_images/702119821979344897/oAC05cEB_400x400.png";
        };
      };
    };
  };
}
