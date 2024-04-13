{disks ? ["/dev/vdb"], ...}: {
  disk = {
    vdb = {
      device = builtins.elemAt disks 0;
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            start = "1MiB";
            end = "100MiB";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            start = "100MiB";
            end = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
  nodev = {
    "/tmp" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=2048M"
      ];
    };
  };
}
