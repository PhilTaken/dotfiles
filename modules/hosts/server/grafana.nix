{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.server.services.grafana;
in
{

  options.phil.server.services.grafana = {
    enable = mkEnableOption "grafana dashboard";
  };

  config = mkIf (cfg.enable) {

  };
}
