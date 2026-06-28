{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  notServer = !config.profiles.${namespace}.starship.server;
  inherit (pkgs) git-credential-oauth;
in
{
  home.packages = [
    pkgs.mergiraf
  ]
  ++ lib.optionals notServer [
    git-credential-oauth
  ];

  home.file.".gitattributes".source = pkgs.runCommandLocal "gitattributes" { } ''
    ${lib.getExe pkgs.mergiraf} languages --gitattributes >> $out
  '';

  programs.difftastic = {
    enable = true;
    git = {
      enable = true;
      mode = "both";
    };
  };

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
    includes = [ { path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig"; } ];
    lfs.enable = false;
    signing.format = null;
    settings = {
      merge.mergiraf = {
        name = "mergiraf";
        driver = "${lib.getExe pkgs.mergiraf} merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
      };
    }
    // lib.attrsets.optionalAttrs notServer {
      credential = {
        helper = [
          "cache --timeout 21600"
          "${lib.getExe git-credential-oauth}"
        ];
        "https://github.com" = {
          helper = [
            ""
            "cache --timeout 21600"
            "${lib.getExe git-credential-oauth} -device"
          ];
        };
      };
    };
  };
}
