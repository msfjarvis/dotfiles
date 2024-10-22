{
  pkgs,
  inputs,
  ...
}:
let
  fonts = {
    emoji = {
      name = "Noto Color Emoji";
      package = pkgs.noto-fonts-color-emoji;
    };
    monospace = {
      name = "JetBrainsMonoNL Nerd Font Mono Regular";
      package = pkgs.nerdfonts;
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
      terminal = 10;
    };
  };
in
{
  catppuccin.accent = "mauve";
  catppuccin.flavor = "mocha";
  catppuccin.pointerCursor.enable = true;

  home.sessionVariables.GTK_THEME = "Catppuccin Mocha";

  home.packages = [
    fonts.emoji.package
    fonts.monospace.package
    fonts.sansSerif.package
    fonts.serif.package
  ];

  dconf.settings = {
    "org/cinnamon/theme" = {
      name = "Catppuccin Mocha";
    };
    "org/cinnamon/desktop/interface" = with fonts; {
      font-name = "${sansSerif.name} ${toString sizes.applications}";
    };
    "org/gnome/desktop/interface" = with fonts; {
      theme = "Catppuccin Mocha";
      cursor-size = 32;
      cursor-theme = "Bibata-Modern-Classic";
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3";
      font-name = "${sansSerif.name} ${toString sizes.applications}";
      document-font-name = "${serif.name} ${toString (sizes.applications - 1)}";
      monospace-font-name = "${monospace.name} ${toString sizes.terminal}";
      picture-uri = "file://${inputs.wallpaper}";
      picture-uri-dark = "file://${inputs.wallpaper}";
    };
    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file://${inputs.wallpaper}";
      picture-uri-dark = "file://${inputs.wallpaper}";
    };
    "org/cinnamon/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file://${inputs.wallpaper}";
      picture-uri-dark = "file://${inputs.wallpaper}";
    };
  };
}
