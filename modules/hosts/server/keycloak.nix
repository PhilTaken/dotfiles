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
      default = "keycloak.home";
    };

    # more options
  };

  config = mkIf (cfg.enable) {
    services.keycloak = {
      enable = cfg.enable;
      frontendUrl = cfg.url;
      extraConfig = {};
    };
  };
}

