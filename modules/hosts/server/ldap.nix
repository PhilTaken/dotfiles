{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  cfg = config.phil.server.services.ldap;
  net = config.phil.network;
in {
  options.phil.server.services.ldap = {
    enable = mkEnableOption "ldap";
    host = mkOption {
      type = types.str;
      default = "ldap";
    };

    domain = mkOption {
      type = types.str;
      default = "${cfg.host}.${net.tld}";
    };

    port = mkOption {
      type = types.port;
      default = 8888;
    };
  };

  # TODO transition to openldap (can sync with keycloak)
  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.hasAttr "public_ip" net.nodes.${config.networking.hostName};
        message = "the ldap node needs a public ip to function properly";
      }
    ];

    sops.secrets."portunus-seed" = {
      owner = config.services.portunus.user;
      restartUnits = ["portunus.service"];
    };

    services.portunus = {
      inherit (cfg) enable port domain;
      seedPath = config.sops.secrets.portunus-seed.path;
      ldap.suffix = builtins.concatStringsSep "," (builtins.map (part: "dc=${part}") (lib.splitString "." cfg.domain));
      ldap.tls = true;
    };

    networking.firewall = {
      allowedTCPPorts = [636];
      allowedUDPPorts = [636];
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {
        inherit (cfg) port;
        public = false;

        # the nixos portunus service requires a custom cert
        extraCert = true;
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
