{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  notServer = !config.profiles.${namespace}.starship.server;
  gcm = pkgs.git-credential-manager.override {
    withGpgSupport = false;
  };
  inherit (pkgs) mergiraf;
in
{
  home.packages = [ mergiraf ] ++ lib.optionals notServer [ gcm ];

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
    includes = [ { path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig"; } ];
    lfs.enable = true;
    extraConfig =
      {
        merge.mergiraf = {
          name = "mergiraf";
          driver = "${lib.getExe mergiraf} merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
        };
      }
      // lib.attrsets.optionalAttrs notServer {
        credential = {
          credentialStore = if pkgs.stdenv.hostPlatform.isDarwin then "keychain" else "secretservice";
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
