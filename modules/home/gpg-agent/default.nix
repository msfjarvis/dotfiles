{pkgs, ...}: {
  services.gpg-agent = {
    enable = !pkgs.stdenv.isDarwin;
    defaultCacheTtl = 3600;
    pinentryFlavor = "gnome3";
    enableBashIntegration = true;
  };
}
