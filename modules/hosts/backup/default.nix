{ pkgs
, config
, lib
, ...
}:
with lib;

let
  cfg = config.phil.backup;
in
{
  options.phil.backup = {
    enable = mkOption {
      description = "enable backup module";
      type = types.bool;
      default = false;
    };

    folders = mkOption {
      description = "folders to backup";
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    services.borgbackup.jobs =
      let
        common-excludes = [
          # Largest cache dirs
          ".cache"
          "*/cache2" # firefox
          "*/Cache"
          ".config/Slack/logs"
          ".config/Code/CachedData"
          ".container-diff"
          ".npm/_cacache"
          # Work related dirs
          "*/node_modules"
          "*/bower_components"
          "*/_build"
          "*/.tox"
          "*/venv"
          "*/.venv"
        ];
        work-dirs = [
          "/home/danbst/dev/company1"
          "/home/danbst/dev/company2"
        ];
        basicBorgJob = name: {
          encryption.mode = "none";
          environment.BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -i /home/danbst/.ssh/id_ed25519";
          environment.BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
          extraCreateArgs = "--verbose --stats --checkpoint-interval 600";
          repo = "ssh://user@example.com//media/backup/${name}";
          compression = "zstd,1";
          startAt = "daily";
          user = "danbst";
          exclude = map (x: paths + "/" + x) common-excludes;
        };
      in
      {
        home-danbst = basicBorgJob "backups/station/home-danbst" // rec {
          paths = "/home/danbst";
          exclude = work-dirs ++ map (x: paths + "/" + x) (common-excludes ++ [
            "Downloads"
          ]);
        };
        home-danbst-downloads = basicBorgJob "backups/station/home-danbst-downloads" // rec {
          paths = "/home/danbst/Downloads";
        };
        extra-drive-important = basicBorgJob "backups/station/extra-drive-important" // rec {
          paths = "/media/extra-drive/important";
        };
      };
  };
}
