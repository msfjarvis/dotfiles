{ lib, ... }:
{
  nix.linux-builder.enable = false;
  nix.linux-builder.config.virtualisation.cores = 2;
  nix.linux-builder.config.virtualisation.memorySize = lib.mkForce 6144;
}
