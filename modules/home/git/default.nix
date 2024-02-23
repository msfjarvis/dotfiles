{
  config,
  lib,
  ...
}: {
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
    includes = lib.mkDefault [
      {path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig";}
    ];
  };
}
