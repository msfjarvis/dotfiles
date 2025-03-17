{ pkgs, ... }:
{
  home.packages = with pkgs; [
    aria2
    curl
    delta
    diskus
    (fastfetch.override {
      x11Support = false;
      waylandSupport = false;
      rpmSupport = false;
      vulkanSupport = false;
    })
    fd
    git-absorb
    git-quickfix
    mosh
    ncdu_1
    neofetch
    nixfmt-rfc-style
    nixpkgs-review
    nvd
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
