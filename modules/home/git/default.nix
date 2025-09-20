{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  notServer = !config.profiles.${namespace}.starship.server;
in
{
  home.packages = [ pkgs.mergiraf ] ++ lib.optionals notServer [ pkgs.git-credential-oauth ];

  home.file.".gitattributes".source = pkgs.runCommandLocal "gitattributes" { } ''
    ${lib.getExe pkgs.mergiraf} languages --gitattributes >> $out
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
    extraConfig = {
      merge.mergiraf = {
        name = "mergiraf";
        driver = "${lib.getExe pkgs.mergiraf} merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
      };
    }
    // lib.attrsets.optionalAttrs notServer {
      credential = {
        helper = [
          "cache --timeout 21600"
          "${lib.getExe pkgs.git-credential-oauth}"
        ];
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
