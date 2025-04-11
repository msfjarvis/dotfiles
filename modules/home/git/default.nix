{
  config,
  lib,
  pkgs,
  system,
  namespace,
  ...
}:
let
  isWorkMachine = lib.strings.hasSuffix "darwin" system;
  isServer = config.profiles.${namespace}.starship.server;
  gcm = pkgs.git-credential-manager.override {
    withGpgSupport = false;
  };
  inherit (pkgs) mergiraf;
in
{
  home.packages = [ mergiraf ] ++ lib.optionals isServer [ gcm ];

  home.file.".gitattributes".source = pkgs.runCommandLocal "gitattributes" { } ''
    ${lib.getExe mergiraf} languages --gitattributes >> $out
  '';

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
    difftastic = {
      enable = true;
      enableAsDifftool = true;
    };
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
        core.attributesfile = "~/.gitattributes";

        help.autocorrect = "prompt";

        init.defaultBranch = "main";

        diff.algorithm = "histogram";
        diff.colorMoved = "plain"; # show code movement in different colors than added and removed lines.
        diff.mnemonicPrefix = true; # replace a/ and b/ in diff header output with where the diff is coming from; i/ (index), w/ (working directory) or c/ commit.
        diff.renames = true;

        log.date = "iso";

        merge.conflictstyle = "zdiff3";

        merge.mergiraf = {
          name = "mergiraf";
          driver = "${lib.getExe mergiraf} merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
        };

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
