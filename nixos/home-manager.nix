{ config, pkgs, ... }:

let customTarball = fetchTarball
  "https://github.com/msfjarvis/custom-nixpkgs/archive/95c6e0efdcd7.tar.gz";
in {
  home.username = "msfjarvis";
  home.homeDirectory = "/home/msfjarvis";
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
    historySize = 1000;
    historyFile = "${config.home.homeDirectory}/.bash_history";
    historyFileSize = 10000;
    historyControl = [
      "ignorespace"
      "erasedups"
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

  programs.vscode = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  home.packages = with pkgs; [
    act
    custom.adb-sync
    custom.adx
    asciinema
    bandwhich
    bat
    bottom
    broot
    cachix
    cargo-edit
    cargo-update
    ccache
    choose
    cmake
    cowsay
    curl
    diff-so-fancy
    custom.diffuse
    direnv
    diskus
    dnscontrol
    dos2unix
    droidcam
    espanso
    exa
    custom.fclones
    fd
    ffmpeg
    figlet
    fzf
    gitAndTools.gh
    gitAndTools.git-absorb
    gitAndTools.git-crypt
    custom.git-quickfix
    glow
    go
    gron
    gitAndTools.hub
    hugo
    hyperfine
    kazam
    libwebp
    lolcat
    magic-wormhole
    meson
    micro
    mosh
    custom.natls
    ncdu
    neofetch
    ninja
    nixfmt
    nodejs-14_x
    oathToolkit
    patchelf
    custom.pidcat
    procs
    python38
    python38Packages.poetry
    python38Packages.virtualenv
    qrencode
    ripgrep
    rustup
    scrcpy
    sd
    shellcheck
    shfmt
    tokei
    topgrade
    vivid
    xclip
    xdotool
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
