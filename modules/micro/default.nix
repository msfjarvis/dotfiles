{
  config,
  lib,
  ...
}: let
  finalTheme = config.lib.stylix.scheme {
    template = ./theme.mustache;
    extension = ".micro";
  };
in {
  home-manager.users.msfjarvis = {
    programs.micro = {
      enable = lib.mkDefault true;
      settings = lib.mkDefault {
        colorscheme = "stylix";
        mkparents = true;
        softwrap = true;
        wordwrap = true;
      };
    };
    xdg.configFile."micro/colorschemes/stylix.micro".source = finalTheme;
  };
}
