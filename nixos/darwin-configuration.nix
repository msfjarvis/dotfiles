{ config, pkgs, ... }:

let customTarball = fetchTarball
  "https://github.com/msfjarvis/custom-nixpkgs/archive/4b83f66a2e42.tar.gz";
in {
  home.username = "msfjarvis";
  home.homeDirectory = "/Users/msfjarvis";
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      custom = import customTarball { };
    };
  };

  programs.aria2 = {
    enable = true;
  };

  programs.bash = {
    enable = true;
    historySize = 100;
    historyFile = "${config.home.homeDirectory}/.bash_history";
    historyFileSize = 1000;
    historyControl = [
      "ignorespace"
      "erasedups"
    ];
    bashrcExtra = ''
    if [ -e "${config.home.homeDirectory}"/.nix-profile/etc/profile.d/nix.sh ]; then
      source "${config.home.homeDirectory}"/.nix-profile/etc/profile.d/nix.sh
    fi
    # Source shell-init from my dotfiles
    source ${config.home.homeDirectory}/git-repos/dotfiles/darwin-init
    # Load completions from system
    if [ -f /usr/share/bash-completion/bash_completion ]; then
      . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
    fi
    # Load completions from Git
    source ${pkgs.git}/share/bash-completion/completions/git
    '';
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "zenburn";
    };
  };

  programs.browserpass = {
    enable = true;
    browsers = [
      "chrome"
    ];
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd -tf";
    defaultOptions = [
      "--height 40%"
    ];
    enableBashIntegration = true;
  };

  programs.git = {
    enable = true;
    ignores = [
      ".envrc"
    ];
    includes = [
      { path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig"; }
    ];
  };

  programs.gpg = {
    enable = true;
  };

  programs.home-manager = {
    enable = true;
  };

  programs.htop = {
    enable = true;
  };

  programs.jq = {
    enable = true;
  };

  programs.lsd = {
    enable = false;
    enableAliases = false;
  };

  programs.password-store = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  home.packages = with pkgs; [
    custom.adb-sync
    custom.adx
    bat
    bottom
    cachix
    choose
    cocoapods
    coreutils
    curl
    diff-so-fancy
    direnv
    diskus
    dos2unix
    exa
    fd
    figlet
    fzf
    gitAndTools.gh
    gitAndTools.git-absorb
    glow
    gitAndTools.hub
    hugo
    lolcat
    magic-wormhole
    micro
    mosh
    ncdu
    neofetch
    nixfmt
    custom.pidcat
    procs
    ripgrep
    shfmt
    tokei
    topgrade
    vivid
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
