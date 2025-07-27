{ pkgs, ... }:
{
  home.packages = with pkgs; [
    aria2
    attic-client
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
    nixfmt
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
