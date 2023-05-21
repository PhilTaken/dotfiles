{
  net,
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.hound;
in {
  options.phil.server.services.hound = {
    enable = mkEnableOption "hound";
    host = mkOption {
      type = types.str;
      default = "hound";
    };

    port = mkOption {
      type = types.port;
      default = 6080;
    };
  };

  config = mkIf cfg.enable {
    services.hound = {
      enable = true;
      listen = ":${toString cfg.port}";
      config = builtins.toJSON {
        dbpath = "${config.services.hound.home}/data";
        repos = lib.mapAttrs (_n: v: v // {detect-ref = true;}) {
          nixpgks.url = "https://www.github.com/nixos/nixpkgs";
          dotfiles = {
            url = "https://gitea.${net.tld}/phil/dotfiles";
            ref = "main";
          };
        };
      };
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = {inherit (cfg) port;};
      homer.apps."${cfg.host}" = {
        show = true;
        settings = {
          name = "hound";
          subtitle = "Code Search";
          tag = "app";
          keywords = "selfhosted code search";
          icon = "fas fa-code";
        };
      };
    };
  };
}
