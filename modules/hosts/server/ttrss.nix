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
      default = "rss.pherzog.xyz";
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
      themePackages = with pkgs; [ tt-rss-theme-feedly ];
    };
  };
}
