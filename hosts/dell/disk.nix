{
  disko.devices.disk.main = {
    type = "disk";
    # Set from `ls -l /dev/disk/by-id` on the dell before installing; disko wipes this disk.
    device = "/dev/disk/by-id/CHANGEME";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        luks = {
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            # Only read while formatting; nixos-anywhere copies it here via --disk-encryption-keys.
            passwordFile = "/tmp/disk.key";
            settings.allowDiscards = true;
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
}
