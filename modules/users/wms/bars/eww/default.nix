{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.wms.bars.eww;
in
{
  options.phil.wms.bars.eww = {
    enable = mkOption {
      description = "enable eww module";
      type = types.bool;
      default = false;
    };

    # more options
  };

  config = mkIf (cfg.enable) {
    programs.eww = {
      enable = true;
      configDir = ./config;
    };
  };
}

