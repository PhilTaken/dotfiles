{
  pkgs,
  config,
  lib,
  net,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.freshrss;
in {
  options.phil.server.services.freshrss = {
    enable = mkEnableOption "freshrss";
    url = mkOption {
      description = "freshrss url (webinterface)";
      default = "rss.${net.tld}";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.freshrss-password = {};

    services.freshrss = {
      enable = true;
      baseUrl = cfg.url;
      defaultUser = "phil";
      passwordFile = config.sops.secrets.freshrss-password.path;
    };
  };
}
