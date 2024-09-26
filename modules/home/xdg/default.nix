{ pkgs, ... }:
{
  xdg = {
    enable = true;
    mime.enable = !pkgs.stdenv.hostPlatform.isDarwin;
  };
}
