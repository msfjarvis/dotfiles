{ pkgs, ... }:
{
  home.packages = with pkgs; [
    aria2
    curl
    delta
    diskus
    fastfetch-unwrapped
    fd
    git-absorb
    git-quickfix
    mosh
    ncdu_1
    nixfmt
    nix-update
    nixpkgs-review
    nvd
    (python3.withPackages (
      ps: with ps; [
        beautifulsoup4
        black
        requests
        virtualenv
      ]
    ))
    ripgrep
    sd
    shellcheck
    shfmt
    sops
    unzip
    vivid
    zip
  ];
}
