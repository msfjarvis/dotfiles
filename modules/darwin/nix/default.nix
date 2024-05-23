{
  lib,
  pkgs,
  config,
  inputs,
  namespace,
  ...
}:
{
  nix =
    lib.${namespace}.mkNixConfig {
      inherit
        lib
        pkgs
        config
        inputs
        ;
    }
    // {
      gc = {
        automatic = true;
        options = "--delete-older-than 3d";
      };
    };
  services.nix-daemon.enable = true;
}
