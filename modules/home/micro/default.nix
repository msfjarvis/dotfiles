{ inputs, ... }:
{
  programs.micro = {
    enable = true;
    settings = {
      colorscheme = "catppuccin-mocha";
      # Too annoying with pi's settings.json and I don't care as much anymore
      eofnewline = false;
      mkparents = true;
      softwrap = true;
      wordwrap = true;
    };
  };
  xdg.configFile = {
    "micro/colorschemes/catppuccin-mocha.micro".source =
      "${inputs.micro-theme}/themes/catppuccin-mocha.micro";
    "micro/colorschemes/catppuccin-latte.micro".source =
      "${inputs.micro-theme}/themes/catppuccin-latte.micro";
  };
}
