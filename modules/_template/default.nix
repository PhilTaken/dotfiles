{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.template;
in {
  options.phil.template = {
    enable = mkOption {
      description = "enable template module";
      type = types.bool;
      default = false;
    };

    # more options
  };

  config = mkIf (cfg.enable) {
    # add config here
  };
}

