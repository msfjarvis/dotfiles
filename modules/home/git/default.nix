{
  config,
  lib,
  host,
  ...
}:
let
  isWorkMachine = host == "Harshs-MacBook-Pro";
in
{
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
    extraConfig = {
      branch.sort = "-committerdate";
      core = {
        autocrlf = "input";
      };
      commit.verbose = true;
      fetch = {
        fsckobjects = true;
        prune = true;
        prunetags = true;
      };
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      push.autoSetupRemote = true;
      receive.fsckObjects = true;
      transfer.fsckobjects = true;
    };
  };
}
