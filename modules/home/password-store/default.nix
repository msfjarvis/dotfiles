{
  pkgs,
  host,
  ...
}: {
  programs.password-store = {
    enable = host == "ryzenbox";
    package =
      (pkgs.pass.override {
        x11Support = false;
        waylandSupport = true;
        dmenuSupport = false;
      })
      .withExtensions (exts: [exts.pass-audit exts.pass-genphrase exts.pass-otp exts.pass-update]);
  };
}
