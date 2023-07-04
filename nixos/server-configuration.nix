{
  config,
  pkgs,
  ...
}: {
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

  programs.browserpass = {enable = false;};

  programs.git = {
    includes = [{path = "${config.home.homeDirectory}/dotfiles/.gitconfig";}];
  };

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
        commands = {"Cargo" = "cargo install-update --all";};
      };
    };
  };

  home.packages = with pkgs; [
    alejandra
    (aria2.overrideAttrs (self: super: {
      buildInputs = (lib.remove pkgs.openssl super.buildInputs) ++ [pkgs.gnutls];
    }))
    cachix
    comma
    curl
    delta
    diskus
    dos2unix
    fd
    healthchecks-monitor
    hub
    git-absorb
    katbin
    micro
    mosh
    ncdu_2
    nil
    nix-init
    nix-update
    nixpkgs-review
    neofetch
    nvd
    ripgrep
    sd
    shellcheck
    shfmt
    unzip
    vivid
    zip
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
