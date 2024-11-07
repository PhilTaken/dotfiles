{
  config,
  lib,
  netlib,
  ...
}: let
  service_name = "immich";
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.${service_name};
in {
  options.phil.server.services.${service_name} = {
    enable = mkEnableOption "immich - fancy photo storage";
    url = mkOption {
      description = "${service_name} url (webinterface)";
      type = types.str;
      default = netlib.domainFor cfg.host;
    };

    port = mkOption {
      description = "${service_name} port (webinterface)";
      type = types.port;
      default = netlib.portFor service_name;
    };

    host = mkOption {
      type = types.str;
      default = service_name;
    };
  };

  config = mkIf cfg.enable {
    services.immich = {
      enable = true;
      host = "0.0.0.0";
      inherit (cfg) port;

      # oauth config is limited to the ui and setting settings
      # both here and in the ui doesnt work so they have to be set manually
      settings = null;
      #settings.server.externalDomain = "https://${cfg.url}";
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {
        inherit (cfg) port;
        public = false;
      };
      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "Immich";
          subtitle = "Fancy photo storage";
          tag = "app";
          keywords = "selfhosted cloud photos";
          logo = "https://immich.app/img/logomark-light.svg";
        };
      };
    };
  };
}
