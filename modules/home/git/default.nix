{
  config,
  lib,
  pkgs,
  host,
  ...
}:
let
  isWorkMachine = host == "Harshs-MacBook-Pro";
  gcm = pkgs.git-credential-manager.override {
    withGpgSupport = false;
  };
in
{
  home.packages = [ gcm ];
  programs.git = {
    enable = true;
    ignores = [
      ".envrc"
      "key.properties"
      "keystore.properties"
      "*.jks"
      ".direnv/"
      "fleet.toml"
      ".DS_Store"
    ];
    includes =
      [ { path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig"; } ]
      ++ lib.optionals isWorkMachine [
        { path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig-work"; }
      ];
    lfs.enable = true;
    extraConfig = {
      credential = {
        credentialStore = "secretservice";
        helper = lib.getExe gcm;
        "https://git.msfjarvis.dev" = {
          provider = "generic";
        };
        "https://github.com" = {
          provider = "github";
        };
      };
      branch.sort = "-committerdate";
      core = {
        autocrlf = "input";
      };
      commit.verbose = true;
      fetch = {
        fsckobjects = true;
        prune = true;
      };
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      push.autoSetupRemote = true;
      receive.fsckObjects = true;
      transfer.fsckobjects = true;
    };
  };
}
