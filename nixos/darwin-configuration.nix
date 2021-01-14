{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs;
    [
    bat
    browserpass
    cacert
    cargo-edit
    cargo-update
    cargo-watch
    coreutils
    direnv
    diskus
    dnscontrol
    fd
    fzf
    gitAndTools.diff-so-fancy
    gitAndTools.gh
    gitAndTools.git-absorb
    gitAndTools.git-crypt
    gitAndTools.hub
    git
    gnumake
    gnused
    gnupg
    gradle
    hugo
    jq
    lsd
    mosh
    micro
    ncdu
    neofetch
    nixfmt
    nodejs-14_x
    oathToolkit
    openssl
    pass
    patchelf
    procs
    ripgrep
    rustup
    shellcheck
    shfmt
    starship
    topgrade
    unrar
    vivid
    zoxide
    ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
