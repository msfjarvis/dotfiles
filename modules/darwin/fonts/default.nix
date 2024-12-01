{ pkgs, ... }:
{
  fonts = {
    packages = [ pkgs.nerd-fonts.iosevka-term ];
  };
}
