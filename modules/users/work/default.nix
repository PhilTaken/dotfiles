{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.git;
  uid = 1000;
  gid = 1000;
in
{
  options.phil.work = {
    enable = mkEnableOption "work";
  };

  config = mkIf (cfg.enable) {
    systemd.user.mounts = {
      prep = {
        Unit = {
          Description = "prep mount";
        };

        Mount = {
          What = "jureca:/p/project/cjicg21/herzog1/prep";
          Where = "$HOME/Documents/work/dev_jureca/";
          Type = "fuse.sshfs";
          Options = "Compression=no,auto_cache,idmap=user";
        };
      };
    };
  };
}
