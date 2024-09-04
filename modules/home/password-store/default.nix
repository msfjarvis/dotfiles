{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.pass;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.pass = {
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
          uri = "https://msfjarvis@git.msfjarvis.dev/msfjarvis/pass-store";
          interval = 600;
        };
      };
    };
  };
}
