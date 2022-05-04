{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.iperf;
in
{

  options.phil.server.services.iperf = {
    enable = mkEnableOption "iperf bandwith benchmark tool";
  };

  config = mkIf (cfg.enable) {
    services.iperf3 = {
      enable = true;
      openFirewall = true;
    };
  };
}
