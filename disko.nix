{
  disk ? "/dev/sda",
  ...
}:
{
  disko.devices = {
    disk = {
      main = {
        device = disk;
        type = "disk";
        content = {
          type = "table";
          format = "msdos";
          partitions = [
            {
              name = "root";
              start = "1MiB";
              end = "-8G";
              part-type = "primary";
              bootable = true;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                extraArgs = [
                  "-L"
                  "nixos"
                ];
              };
            }
            {
              name = "swap";
              start = "-8G";
              end = "100%";
              content = {
                type = "swap";
                extraArgs = [
                  "-L"
                  "swap"
                ];
              };
            }
          ];
        };
      };
    };
  };
}
