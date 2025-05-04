{ pkgs, ... }:
{
  services.gpg-agent = {
    enable = !pkgs.stdenv.hostPlatform.isDarwin;
    defaultCacheTtl = 3600;
    enableBashIntegration = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };
}
