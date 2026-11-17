{
  disk ? "/dev/sda",
  # "uefi" (GPT + EFI system partition) or "bios" (msdos, GRUB in the MBR).
  bootMode ? "bios",
  ...
}:
let
  uefi = bootMode == "uefi";

  espPartition = {
    name = "ESP";
    start = "1MiB";
    end = "513MiB";
    bootable = true;
    content = {
      type = "filesystem";
      format = "vfat";
      mountpoint = "/boot";
      extraArgs = [
        "-n"
        "boot"
      ];
    };
  };

  rootPartition = {
    name = "root";
    start = if uefi then "513MiB" else "1MiB";
    end = "-8G";
    part-type = "primary";
    bootable = !uefi;
    content = {
      type = "filesystem";
      format = "ext4";
      mountpoint = "/";
      extraArgs = [
        "-L"
        "nixos"
      ];
    };
  };

  swapPartition = {
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
  };
in
{
  disko.devices = {
    disk = {
      main = {
        device = disk;
        type = "disk";
        content = {
          type = "table";
          format = if uefi then "gpt" else "msdos";
          partitions = (if uefi then [ espPartition ] else [ ]) ++ [
            rootPartition
            swapPartition
          ];
        };
      };
    };
  };
}
