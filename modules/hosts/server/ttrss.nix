{
  pkgs,
  config,
  lib,
  netlib,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.phil.server.services.ttrss;
in {
  options.phil.server.services.ttrss.enable = mkEnableOption "tiny tiny rss";

  config = mkIf cfg.enable {
    services.tt-rss = {
      enable = true;
      auth = {
        autoCreate = true;
        autoLogin = true;
      };
      registration.enable = false;
      selfUrlPath = "https://${netlib.domainFor "rss"}";
      themePackages = with pkgs; [tt-rss-theme-feedly];
    };
  };
}
