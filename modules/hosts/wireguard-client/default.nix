{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.wirgeguard-client;
in
{
  options.phil.wirgeguard-client = {
    enable = mkOption {
      description = "enable wirgeguard-client module";
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

