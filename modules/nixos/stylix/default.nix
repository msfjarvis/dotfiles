{ pkgs, namespace, ... }:
{
  stylix = {
    autoEnable = false;
    enable = true;
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
  snowfallorg.users.msfjarvis.home.config = {
    stylix = {
      targets = {
        bat.enable = true;
        fzf.enable = true;
      };
    };
  };
}
