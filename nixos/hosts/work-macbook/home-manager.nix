{pkgs, ...}: {
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

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [exts.pass-audit exts.pass-genphrase exts.pass-otp exts.pass-update]);
  };

  # home-manager uses nmd to build these which triggers a Nix bug
  # https://github.com/NixOS/nix/issues/8485
  manual.manpages.enable = false;
}
