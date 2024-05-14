{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
{
  nix =
    lib.jarvis.mkNixConfig {
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
