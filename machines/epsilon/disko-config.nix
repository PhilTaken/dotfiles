{disks ? ["/dev/vdb"], ...}: {
  disk = {
    vdb = {
      device = builtins.elemAt disks 0;
      type = "disk";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "ESP";
            start = "1MiB";
            end = "100MiB";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "root";
            start = "100MiB";
            end = "100%";
            part-type = "primary";
            bootable = true;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          }
        ];
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
