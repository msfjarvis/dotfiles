{
  pkgs,
  lib,
  namespace,
  ...
}:
{
  stylix = {
    autoEnable = false;
    enable = lib.mkDefault true;
    # Keep the evaluation-time copy in sync with the pinned base16-schemes package.
    # Run scripts/update-stylix-palette.sh after updating nixpkgs.
    base16Scheme = ./catppuccin-mocha.yaml;
    targets = {
      console.enable = true;
      nixos-icons.enable = true;
    };

    cursor = {
      package = pkgs.${namespace}.michi-cursors;
      name = "michi";
      size = 32;
    };
  };
}
