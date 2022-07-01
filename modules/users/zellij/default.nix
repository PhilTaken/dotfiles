{ pkgs
, config
, lib
, ...
}@inputs:
with lib;

let
  cfg = config.phil.zellij;
in
rec {
  options.phil.zellij = {
    enable = mkEnableOption "zellij";
  };

  config = mkIf (cfg.enable) {
    programs.zellij = {
      enable = true;
      settings = {
        theme = "nord";
      };
    };
  };
}
