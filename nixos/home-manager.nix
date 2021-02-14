{ config, pkgs, ... }:

{
  home.username = "msfjarvis";
  home.homeDirectory = "/home/msfjarvis";

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
    ];
    bashrcExtra = "
    # Source shell-init from my dotfiles
    source ${config.home.homeDirectory}/git-repos/dotfiles/shell-init
    # Load completions from system
    if [ -f /usr/share/bash-completion/bash_completion ]; then
      . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
    fi
    # Load completions from Git
    source ${pkgs.git}/share/bash-completion/completions/git
    ";
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
#    userName = "Harsh Shandilya";
#    userEmail = "me@msfjarvis.dev";
#    ignores = [
#      ".envrc"
#    ];
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
    enable = true;
    enableAliases = true;
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
    act
    asciinema
    bandwhich
    bat
    bottom
    cachix
    ccache
    choose
    cmake
    cowsay
    curl
    diff-so-fancy
    direnv
    diskus
    dnscontrol
    dos2unix
    fd
    ffmpeg
    figlet
    fzf
    gitAndTools.gh
    gitAndTools.git-absorb
    glow
    go
    gron
    gitAndTools.hub
    hugo
    hyperfine
    libwebp
    lolcat
    meson
    micro
    ncdu
    neofetch
    ninja
    nixfmt
    nodejs-14_x
    oathToolkit
    patchelf
    procs
    ripgrep
    rustup
    scrcpy
    shellcheck
    shfmt
    tokei
    topgrade
    vivid
    xclip
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
