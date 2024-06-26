{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.ttrss;
  net = config.phil.network;
in {
  options.phil.server.services.ttrss = {
    enable = mkEnableOption "tiny tiny rss";
    url = mkOption {
      description = "ttrss url (webinterface)";
      default = "rss.${net.tld}";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    services.tt-rss = {
      enable = true;
      auth = {
        autoCreate = true;
        autoLogin = true;
      };
      registration.enable = false;
      selfUrlPath = "https://${cfg.url}";
      themePackages = with pkgs; [tt-rss-theme-feedly];
    };
  };
}
