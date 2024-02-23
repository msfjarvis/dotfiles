{pkgs, ...}: {
  xdg = {
    enable = true;
    mime.enable = !pkgs.stdenv.isDarwin;
  };
}
