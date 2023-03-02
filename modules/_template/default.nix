{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkEnableOption mkIf types;
  cfg = config.phil.template;
in
{
  options.phil.template = {
    enable = mkEnableOption "template";

    # more options
  };

  config = mkIf cfg.enable {
    # add config here
  };
}

