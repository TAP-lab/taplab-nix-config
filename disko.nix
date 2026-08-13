{ disk ? "/dev/sda", ... }:
{
  disko.devices = {
    disk = {
      main = {
        device = disk;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            swap = {
              size = "8G";
              content = {
                type = "swap";
              };
            };
          };
        };
      };
    };
  };
}
