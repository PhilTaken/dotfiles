{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.ttrss;
in
{

  options.phil.server.services.ttrss = {
    enable = mkEnableOption "tiny tiny rss";
    url = mkOption {
      description = "ttrss url (webinterface)";
      type = types.str;
    };
  };

  config = mkIf (cfg.enable) {
    services.tt-rss = {
      enable = true;
      auth = {
        autoCreate = true;
        autoLogin = true;
      };
      registration.enable = false;
      selfUrlPath = "https://rss.pherzog.xyz";
      virtualHost = "rss.pherzog.xyz";
      themePackages = with pkgs; [ tt-rss-theme-feedly ];
    };
  };
}
