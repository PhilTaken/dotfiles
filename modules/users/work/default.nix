{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.work;
in
{
  options.phil.work = {
    enable = mkOption {
      description = "enable work module";
      type = types.bool;
      default = false;
    };

    # more options
  };

  config = mkIf cfg.enable {
    # add config here
    home.file.".aws/credentials".source = config.lib.file.mkOutOfStoreSymlink "/run/secrets/aws-credentials";
  };
}

