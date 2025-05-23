{
  lib,
  pkgs,
  namespace,
  ...
}:
{
  nix =
    lib.${namespace}.mkNixConfig {
      inherit lib pkgs;
    }
    // {
      extraOptions = ''
        experimental-features = auto-allocate-uids cgroups flakes nix-command
      '';
      gc = {
        automatic = true;
        options = "--delete-older-than 3d";
      };
      settings = {
        trusted-users = [ "msfjarvis" ];
        sandbox = false;
      };
      # Linux builder causes conflicts here
      generateNixPathFromInputs = false;
      generateRegistryFromInputs = false;
    };
}
