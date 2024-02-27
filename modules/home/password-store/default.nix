{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.profiles.pass;
in {
  options.profiles.pass = with lib; {
    enable = mkEnableOption "Enable password-store and related stuff";
  };
  config = lib.mkIf cfg.enable {
    programs.browserpass = {
      enable = true;
      browsers = ["firefox"];
    };
    programs.password-store = {
      enable = true;
      package =
        (pkgs.pass.override {
          x11Support = false;
          waylandSupport = true;
          dmenuSupport = false;
        })
        .withExtensions (exts: [exts.pass-audit exts.pass-genphrase exts.pass-otp exts.pass-update]);
    };
    services.git-sync = {
      enable = true;
      repositories = lib.mkDefault {
        password-store = {
          path = config.programs.password-store.settings.PASSWORD_STORE_DIR;
          uri = "git+ssh://msfjarvis@github.com:msfjarvis/pass-store.git";
          interval = 600;
        };
      };
    };
  };
}
