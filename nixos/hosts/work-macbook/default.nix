{pkgs, ...}: {
  users.users.msfjarvis = {
    name = "msfjarvis";
    home = "/Users/msfjarvis";
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override {
        fonts = ["CascadiaCode" "FiraCode" "Inconsolata" "JetBrainsMono"];
      })
    ];
  };

  homebrew = {
    enable = true;
    brews = [
      "cocoapods"
      "carthage"
      "gnu-sed"
      "ruby"
      "JakeWharton/repo/dependency-watch"
    ];
    taps = [
      "JakeWharton/repo"
    ];
  };

  nix = {
    settings = {
      trusted-substituters = [
        "https://cache.nixos.org/"
        "https://cache.garnix.io/"
        "https://nix-community.cachix.org/"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = ["msfjarvis" "root"];
    };
  };

  environment.systemPackages = with pkgs; [
    adx
    awscli2
    coreutils
    dasel
    diffuse-bin
    flock
    gdrive
    gradle-completion
    git-absorb
    go
    hub
    katbin
    maestro
    openssh
    openssl
    pidcat
    scrcpy
  ];

  programs.gnupg.agent.enable = true;
  programs.man.enable = true;

  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
