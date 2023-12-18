_: {
  targets.genericLinux.enable = false;
  xdg.enable = false;
  xdg.mime.enable = false;
  services.gpg-agent.enable = false;
  services.git-sync.enable = false;
  programs.bash = {
    initExtra = ''
      # Load completions from system
      if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
      elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
      fi
      # Source shell-init from my dotfiles
      source /Users/msfjarvis/git-repos/dotfiles/darwin-init
      # Load gcloud init scripts
      source /Users/msfjarvis/.bash_profile_gcloud
      export BASH_SILENCE_DEPRECATION_WARNING=1
    '';
  };

  programs.browserpass = {
    enable = true;
    browsers = ["chrome"];
  };

  programs.git = {
    includes = [
      {path = "/Users/msfjarvis/git-repos/dotfiles/.gitconfig";}
      {
        path = "/Users/msfjarvis/git-repos/dotfiles/.gitconfig-work";
      }
    ];
  };
}
