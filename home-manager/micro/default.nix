{
  dracula-micro,
  lib,
  ...
}: {
  programs.micro = {
    enable = lib.mkDefault true;
    settings = lib.mkDefault {
      colorscheme = "dracula";
      mkparents = true;
      softwrap = true;
      wordwrap = true;
    };
  };
  xdg.configFile."micro/colorschemes/dracula.micro".source = dracula-micro;
}
