{
  config,
  lib,
  host,
  ...
}: let
  isWorkMachine = host == "Harshs-MacBook-Pro";
in {
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
      [
        {path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig";}
      ]
      ++ lib.optionals isWorkMachine [
        {path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig-work";}
      ];
  };
}
