{ lib, ... }:
{
  nix.linux-builder.enable = true;
  nix.linux-builder.config.virtualisation.cores = 2;
  nix.linux-builder.config.virtualisation.memorySize = lib.mkForce 6144;
}
