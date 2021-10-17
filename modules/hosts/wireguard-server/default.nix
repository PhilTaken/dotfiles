{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.wirgeguard-server;
in
{
  options.phil.wirgeguard-server = {
    enable = mkOption {
      description = "enable wirgeguard-server module";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    networking.firewall.interfaces = {
      "valhalla" = {
        allowedUDPPorts = [
          5353
        ];
      };
    };
  };
}

