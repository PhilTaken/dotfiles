{ pkgs
, config
, lib
, ...
}:

let
  inherit (lib) mkOption mkIf types;
  cfg = config.phil.backup;
  mkRepo = name: "${cfg.repo}/${name}";
  mkJob = name: paths: {
    inherit paths;
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
    enable = mkOption {
      description = "enable backup module";
      type = types.bool;
      default = false;
    };

    jobs = mkOption {
      description = "paths to backup";
      type = types.attrsOf types.str;
      default = {};
    };

    repo = mkOption {
      type = types.str;
      description = "repo to backup to";
    };
  };

  config = mkIf cfg.enable {
    services.borgbackup.jobs = lib.mapAttrs mkJob cfg.jobs;
  };
}
