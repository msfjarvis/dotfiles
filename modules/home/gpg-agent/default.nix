{
  pkgs,
  lib,
  ...
}: {
  services.gpg-agent = {
    enable = !pkgs.stdenv.isDarwin;
    defaultCacheTtl = 3600;
    pinentryFlavor = null;
    enableBashIntegration = true;
    extraConfig = ''
      pinentry-program ${lib.getExe pkgs.pinentry-gnome3}
    '';
  };
}
