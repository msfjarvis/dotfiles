{pkgs, ...}: {
  services.gpg-agent = {
    enable = !pkgs.stdenv.isDarwin;
    defaultCacheTtl = 3600;
    enableBashIntegration = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };
}
