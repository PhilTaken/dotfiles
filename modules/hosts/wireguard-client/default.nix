{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.innernet-client;
in
{
  options.phil.innernet-client = {
    enable = mkOption {
      description = "enable innernet-client module";
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

