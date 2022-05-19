{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.wms.xmonad;
in
{
  options.phil.wms.xmonad = {
    enable = mkOption {
      description = "enable xmonad module";
      type = types.bool;
      default = false;
    };

    # more options
  };

  config = mkIf (cfg.enable) {
    # add config here
  };
}

