{ inputs, ... }:
{
  programs.micro = {
    enable = true;
    settings = {
      colorscheme = "custom";
      # Too annoying with pi's settings.json and I don't care as much anymore
      eofnewline = false;
      mkparents = true;
      softwrap = true;
      wordwrap = true;
    };
  };
  xdg.configFile."micro/colorschemes/custom.micro".source =
    "${inputs.micro-theme}/themes/catppuccin-mocha.micro";
}
