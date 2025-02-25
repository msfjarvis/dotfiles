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

        column.ui = "auto";

        commit.verbose = true;

        core.autocrlf = "input";

        help.autocorrect = "prompt";

        init.defaultBranch = "main";

        diff.algorithm = "histogram";
        diff.colorMoved = "plain"; # show code movement in different colors than added and removed lines.
        diff.mnemonicPrefix = true; # replace a/ and b/ in diff header output with where the diff is coming from; i/ (index), w/ (working directory) or c/ commit.
        diff.renames = true;

        log.date = "iso";

        merge.conflictstyle = "zdiff3";

        pull.rebase = true;

        push.autoSetupRemote = true;
        push.default = "simple";
        push.followTags = true;

        fetch.all = true;
        fetch.fsckobjects = true;
        fetch.prune = true;
        fetch.pruneTags = true;

        rerere.enabled = true;
        rerere.autoupdate = true;

        rebase.autoSquash = true;
        rebase.autoStash = true;
        rebase.updateRefs = true;

        receive.fsckObjects = true;

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
