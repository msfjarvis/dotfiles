{ inputs, pkgs, ... }:
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
  xdg.configFile."micro/colorschemes/custom.micro".source =
    let
      variant = if pkgs.stdenv.hostPlatform.isDarwin then "latte" else "mocha";
    in
    "${inputs.micro-theme}/src/catppuccin-${variant}.micro";
}
