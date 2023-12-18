{
  pkgs,
  lib,
  ...
}: {
  programs.password-store = {
    enable = lib.mkDefault true;
    package = lib.mkDefault (pkgs.pass.withExtensions (exts: [exts.pass-audit exts.pass-genphrase exts.pass-otp exts.pass-update]));
  };
}
