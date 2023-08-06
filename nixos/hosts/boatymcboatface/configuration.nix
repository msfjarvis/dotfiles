{
  config,
  pkgs,
  ...
}: let
  defaultPkgs = import ../../modules/default-packages.nix;
in {
  home.username = "msfjarvis";
  home.homeDirectory = "/home/msfjarvis";
  targets.genericLinux.enable = true;

  programs.bash = {
    historyFile = "${config.home.homeDirectory}/.bash_history";
    initExtra = ''
      # Load completions from system
      if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
      elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
      fi
      # Source shell-init from my dotfiles
      source ${config.home.homeDirectory}/dotfiles/shell-init
      # _byobu_sourced=1 . /usr/bin/byobu-launch 2>/dev/null || true
    '';
  };

  programs.git = {
    includes = [{path = "${config.home.homeDirectory}/dotfiles/.gitconfig";}];
  };

  programs.nix-index-database.comma.enable = true;

  programs.starship = {
    settings = {
      format = "$directory$git_branch$git_state$git_status➜ ";
      character.disabled = true;
    };
  };

  programs.topgrade = {
    enable = true;

    settings = {
      misc = {
        only = ["bin" "system" "micro"];
        set_title = false;
        cleanup = true;
      };
    };
  };

  home.packages = with pkgs;
    [
      katbin
      healthchecks-monitor
      nvd
    ]
    ++ (defaultPkgs pkgs);
}
