{ config
, lib
, ...
}:

let
  inherit (lib) mkOption mkEnableOption mkIf types;
  cfg = config.phil.backup;

  mkRepo = name: "${cfg.repo}/${name}";
  mkJob = name: config: {
    inherit (config) paths preHook postHook;

    repo = mkRepo name;

    exclude = [
      # very large paths
      "/var/lib/docker"
      "/var/lib/systemd"
      "/var/lib/libvirt"

      # temporary files created by cargo
      "**/target"
    ];

    encryption.mode = "none";

    environment.BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
    extraCreateArgs = "--verbose --stats --checkpoint-interval 600";
    compression = "auto,zstd";
    startAt = "daily";
  };
in
{
  options.phil.backup = {
    enable = mkEnableOption "backup";
    jobs = mkOption {
      description = "paths to back up or ";
      type = types.attrsOf (types.submodule ({ ... }: {
        options = {
          paths = mkOption {
            type = types.listOf types.str;
          };

          preHook = mkOption {
            type = types.lines;
            default = "";
          };

          postHook = mkOption {
            type = types.lines;
            default = "";
          };
        };
      }));
      default = {};
    };

    repo = mkOption {
      type = types.str;
      description = "repo to back up to";
    };
  };

  config = mkIf cfg.enable {
    services.borgbackup.jobs = lib.mapAttrs mkJob cfg.jobs;
  };
}
