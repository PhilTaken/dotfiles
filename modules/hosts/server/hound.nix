{ pkgs
, net
, config
, lib
, ...
}:

let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.hound;
in
{
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
        repos = {
          serokell-nix = {
            url = "https://www.github.com/serokell/serokell.nix";
            ms-between-poll = 20000;
          };
          nixpgks = {
            url = "https://www.github.com/nixos/nixpkgs";
            ms-between-poll = 20000;
          };
          dotfiles.url = "https://gitea.${net.tld}/phil/dotfiles";
        };
      };
    };

    phil.server.services = {
      caddy.proxy."${cfg.host}" = { inherit (cfg) port; };
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
