{
  config,
  lib,
  pkgs,
  host,
  namespace,
  ...
}:
let
  isWorkMachine = host == "Harshs-MacBook-Pro";
  isServer = config.profiles.${namespace}.starship.server;
  gcm = pkgs.git-credential-manager.override {
    withGpgSupport = false;
  };
in
{
  home.packages = lib.optionals isServer [ gcm ];
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
    extraConfig =
      {
        branch.sort = "-committerdate";
        core.autocrlf = "input";
        commit.verbose = true;
        diff.algorithm = "histogram";
        diff.colorMoved = "plain"; # show code movement in different colors than added and removed lines.
        diff.mnemonicPrefix = true; # replace a/ and b/ in diff header output with where the diff is coming from; i/ (index), w/ (working directory) or c/ commit.
        fetch.all = true;
        fetch.fsckobjects = true;
        fetch.prune = true;
        fetch.pruneTags = true;
        help.autocorrect = "prompt";
        init.defaultBranch = "main";
        log.date = "iso";
        merge.conflictstyle = "zdiff3";
        pull.rebase = true;
        push.autoSetupRemote = true;
        rebase.autostash = true;
        receive.fsckObjects = true;
        rerere.enabled = true; # record before and after states of rebase conflicts.
        rerere.autoupdate = true; # automatically re-apply discovered resolutions.
        tag.sort = "version:refname";
        transfer.fsckobjects = true;
      }
      // lib.attrsets.optionalAttrs (!isServer) {
        credential = {
          credentialStore = if isWorkMachine then "keychain" else "secretservice";
          helper = lib.getExe gcm;
          "https://git.msfjarvis.dev" = {
            provider = "generic";
          };
          "https://github.com" = {
            provider = "github";
          };
        };
      };
  };
}
