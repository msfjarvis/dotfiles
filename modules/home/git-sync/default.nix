{
  config,
  lib,
  host,
  ...
}: {
  services.git-sync = {
    enable = host == "ryzenbox";
    repositories = lib.mkDefault {
      password-store = {
        path = config.programs.password-store.settings.PASSWORD_STORE_DIR;
        uri = "git+ssh://msfjarvis@github.com:msfjarvis/pass-store.git";
        interval = 600;
      };
    };
  };
}
