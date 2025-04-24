{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot.supportedFilesystems = [ "ntfs" ];
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  disko.devices = {
    disk = {
      main = {
        # When using disko-install, we will overwrite this value from the commandline
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
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
  };

  fileSystems."/media" = {
    device = "/dev/disk/by-uuid/1d9cbc92-8ea9-4ae7-8c8f-5f72c3d75626";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  fileSystems."/mediahell" = {
    device = "/dev/disk/by-uuid/776C677B7E1D53F0";
    fsType = "ntfs-3g";
    options = [
      "nofail"
      "uid=0"
      "gid=users"
      "umask=002"
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
