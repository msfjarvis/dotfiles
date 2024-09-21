{
  lib,
  pkgs,
  inputs,
  namespace,
  ...
}:
{
  nix = lib.${namespace}.mkNixConfig { inherit lib pkgs inputs; } // {
    package = pkgs.nixVersions.stable;
    gc = {
      automatic = true;
      options = "--delete-older-than 3d";
    };
    # Linux builder causes conflicts here
    generateNixPathFromInputs = false;
    generateRegistryFromInputs = false;
  };
  services.nix-daemon.enable = true;
}
