{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    aria2
    byobu
    cachix
    curl
    delta
    diskus
    dos2unix
    fd
    git-absorb
    git-quickfix
    hub
    mosh
    ncdu_1
    neofetch
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
    sops
    tailscale
    tmux
    unzip
    vivid
    zip

    snowfallorg.flake
  ];
}
