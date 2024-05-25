{
  lib,
  pkgs,
  namespace,
  ...
}:
{
  nix = lib.${namespace}.mkNixConfig { inherit lib pkgs; } // {
    gc = {
      automatic = true;
      options = "--delete-older-than 3d";
    };
  };
  services.nix-daemon.enable = true;
}
