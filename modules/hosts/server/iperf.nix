{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkOption mkIf types mkEnableOption;
  cfg = config.phil.server.services.iperf;
in
{

  options.phil.server.services.iperf = {
    enable = mkEnableOption "iperf bandwith benchmark tool";
    port = mkOption {
      type = types.port;
      default = 5201;
    };
  };

  config = mkIf cfg.enable {
    services.iperf3 = {
      inherit (cfg) port;
      enable = true;
    };

    networking.firewall = {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };
  };
}
