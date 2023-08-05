{config, ...}: {
  imports = [../../home-manager-common.nix];
  programs.bash = {
    historyFile = "${config.home.homeDirectory}/.bash_history";
    initExtra = ''
      # Source shell-init from my dotfiles
      source ${config.home.homeDirectory}/dotfiles/shell-init
    '';
  };
  programs.git = {
    includes = [
      {path = "${config.home.homeDirectory}/dotfiles/.gitconfig";}
    ];
  };
}
