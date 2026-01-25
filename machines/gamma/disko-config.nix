{
  disks ? [
    "/dev/nvme0n1"
    "/dev/sdb1"
  ],
  ...
}:
{
  disk = {
    vdb = {
      device = builtins.elemAt disks 0;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            end = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            name = "root";
            end = "-0";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
    seagate = {
      device = builtins.elemAt disks 1;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          root = {
            uuid = "b4613a63-3edc-ca4f-bec3-9cf50717959b";
            name = "seagate";
            end = "-0";
            content = {
              type = "filesystem";
              format = "btrfs";
              mountpoint = "/seagate";
              mountOptions = [
                "defaults"
                "noatime"
                "compress=zstd"
                "autodefrag"
                "user"
                "rw"
                "exec"
              ];
            };
          };
        };
      };
    };
  };
}
