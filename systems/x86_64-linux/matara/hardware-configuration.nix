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

  fileSystems."/mediahell" = {
    device = "/dev/disk/by-uuid/710b3729-811b-4844-a6ef-3ff343822f42";
    fsType = "ext4";
  };

  fileSystems."/media" = {
    device = "/dev/disk/by-uuid/776C677B7E1D53F0";
    fsType = "ntfs-3g";
    options = [
      "nofail"
      "uid=msfjarvis"
      "gid=users"
      "umask=002"
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
