{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.nix-serve;
in
{
  options.phil.server.services.nix-serve = {
    enable = mkEnableOption "sharing nix store";
    ng = mkOption {
      type = types.bool;
      default = false;
    };

    host = mkOption {
      type = types.str;
      default = "nix-store";
    };

    port = mkOption {
      type = types.port;
      default = 5000;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.nix-serve-secret-key = { };
    phil.server.services.caddy.proxy.${cfg.host} = cfg.port;

    services.nix-serve = {
      enable = true;
      package = if cfg.ng then pkgs.haskellPackages.nix-serve-ng else pkgs.nix-serve;
      secretKeyFile = config.sops.secrets.nix-serve-secret-key.path;
      inherit (cfg) port;
    };
  };
}
