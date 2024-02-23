{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  boot.supportedFilesystems = ["ntfs"];
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  fileSystems."/media" = {
    device = "/dev/disk/by-uuid/1d9cbc92-8ea9-4ae7-8c8f-5f72c3d75626";
    fsType = "ext4";
    options = [
      "nofail"
    ];
  };
}
