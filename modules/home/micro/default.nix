{ inputs, ... }:
{
  programs.micro = {
    enable = true;
    settings = {
      colorscheme = "custom";
      mkparents = true;
      softwrap = true;
      wordwrap = true;
    };
  };
  xdg.configFile."micro/colorschemes/custom.micro".source = inputs.micro-theme;
}
