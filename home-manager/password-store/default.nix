{
  pkgs,
  lib,
  ...
}: {
  programs.password-store = {
    enable = lib.mkDefault true;
    package = lib.mkDefault ((pkgs.pass.override {
        x11Support = false;
        waylandSupport = true;
        dmenuSupport = false;
      })
      .withExtensions (exts: [exts.pass-audit exts.pass-genphrase exts.pass-otp exts.pass-update]));
  };
}
