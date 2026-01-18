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
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
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
