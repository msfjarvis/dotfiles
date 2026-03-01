{ config, lib, ... }:
{
  programs.home-manager = {
    enable = true;
  };

  # Workaround for https://github.com/nix-community/home-manager/issues/8786
  home.activation.installPackages = lib.mkForce (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      nixProfileRemove home-manager-path
      if [[ -e ${config.home.profileDirectory}/manifest.json ]]; then
        run nix profile install ${config.home.path}
      else
        run nix-env -i ${config.home.path}
      fi
    ''
  );
}
