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
}
