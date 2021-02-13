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
    initExtra = "source ${config.home.homeDirectory}/git-repos/dotfiles/shell-init";
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

  programs.gh = {
    enable = true;
    editor = "micro";
    gitProtocol = "ssh";
  };

#  Disabled until I make this match the .gitconfig file
#  programs.git = {
#    enable = true;
#    userName = "Harsh Shandilya";
#    userEmail = "me@msfjarvis.dev";
#    ignores = [
#      ".envrc"
#    ];
#  };

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
