{ pkgs, lib, ... }:
{
  programs.bat = {
    enable = true;
    config = {
      theme = lib.mkDefault (if pkgs.stdenv.hostPlatform.isDarwin then "catppuccin-latte" else "zenburn");
    };
  };
}
