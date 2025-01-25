{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot.supportedFilesystems = [ "ntfs" ];
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  # TODO(msfjarvis): change to real values
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6c1ecd8b-8365-4993-8acf-441eb680576c";
    fsType = "ext4";
  };

  # TODO(msfjarvis): change to real values
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/ECEE-915B";
    fsType = "vfat";
  };

  fileSystems."/media" = {
    device = "/dev/disk/by-uuid/1d9cbc92-8ea9-4ae7-8c8f-5f72c3d75626";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
