{ pkgs, ... }:
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
      package = pkgs.catppuccin-cursors.mochaMauve;
      name = "catppuccin-mocha-mauve-cursors";
    };

    fonts = {
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-color-emoji;
      };
      monospace = {
        name = "IosevkaTerm Nerd Font Regular";
        package = pkgs.nerd-fonts.iosevka-term;
      };
      sansSerif = {
        name = "Roboto Regular";
        package = pkgs.roboto;
      };
      serif = {
        name = "Roboto Serif 20pt Regular";
        package = pkgs.roboto-serif;
      };
      sizes = {
        applications = 12;
        terminal = 12;
      };
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
