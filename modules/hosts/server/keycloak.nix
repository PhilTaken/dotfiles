{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.keycloak;
in
{
  options.phil.server.services.keycloak = {
    enable = mkOption {
      description = "enable keycloak module";
      type = types.bool;
      default = false;
    };

    url = mkOption {
      description = "webinterface url";
      type = types.str;
      default = "keycloak.pherzog.xyz";
    };

    # more options
  };

  config = mkIf cfg.enable {
    sops.secrets.keycloak-dbpass = { };

    services.keycloak = {
      inherit (cfg) enable;
      database = {
        passwordFile = config.sops.secrets.keycloak-dbpass.path;
      };
      settings = {
        hostname = cfg.url;
      };
    };
  };
}

