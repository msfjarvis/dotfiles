{ pkgs, lib, ... }:
{
  services.gpg-agent = {
    enable = !pkgs.stdenv.hostPlatform.isDarwin;
    defaultCacheTtl = 3600;
    enableBashIntegration = true;
    pinentry.package = lib.mkDefault pkgs.pinentry-gnome3;
  };
}
