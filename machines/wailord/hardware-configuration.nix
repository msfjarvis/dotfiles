{modulesPath, ...}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.initrd.availableKernelModules = ["ata_piix" "uhci_hcd" "xen_blkfront"];
  boot.initrd.kernelModules = ["nvme"];
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/CA1A-B46F";
    fsType = "vfat";
  };
  fileSystems."/" = {
    device = "/dev/vda4";
    fsType = "ext4";
  };
}
