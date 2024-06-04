{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.phil.server.services.ldap;
  net = config.phil.network;
  domain = "${cfg.host}.${net.tld}";
in {
  options.phil.server.services.ldap = {
    enable = mkEnableOption "ldap";
    host = mkOption {
      type = types.str;
      default = "ldap";
    };

    port = mkOption {
      type = types.port;
      default = 8888;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."portunus-seed" = {
      owner = config.services.portunus.user;
      restartUnits = ["portunus.service"];
    };

    services.portunus = {
      inherit (cfg) enable;
      inherit domain;
      seedPath = config.sops.secrets.portunus-seed.path;
      ldap.suffix = builtins.concatStringsSep "," (builtins.map (part: "dc=${part}") (lib.splitString "." domain));
      ldap.tls = true;
    };

    # TODO open ldap port
    # networking.firewall.interfaces.${net.networks.default.interfaceName} = {
    #   allowedTCPPorts = [636];
    #   allowedUDPPorts = [636];
    # };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {
        inherit (cfg) port;
        #public = true;
      };

      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Portunus";
          subtitle = "LDAP/Auth Server";
          tag = "auth";
          keywords = "selfhosted ldap auth";
          logo = "https://github.com/majewsky/portunus/raw/master/doc/img/logo.png";
        };
      };
    };
  };
}
