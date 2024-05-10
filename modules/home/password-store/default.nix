{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.profiles.pass;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.pass = {
    enable = mkEnableOption "Enable password-store and related stuff";
  };
  config = mkIf cfg.enable {
    programs.browserpass = {
      enable = true;
      browsers = [ "firefox" ];
    };
    programs.password-store = {
      enable = true;
      package =
        (pkgs.pass.override {
          x11Support = false;
          waylandSupport = true;
          dmenuSupport = false;
        }).withExtensions
          (
            exts: with exts; [
              pass-genphrase
              pass-otp
              pass-update
            ]
          );
    };
    services.git-sync = {
      enable = true;
      repositories = {
        password-store = {
          path = config.programs.password-store.settings.PASSWORD_STORE_DIR;
          uri = "git+ssh://msfjarvis@github.com:msfjarvis/pass-store.git";
          interval = 600;
        };
      };
    };
  };
}
