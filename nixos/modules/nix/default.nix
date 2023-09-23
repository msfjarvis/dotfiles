_: {
  nix = {
    settings = {
      trusted-substituters = [
        "https://cache.nixos.org/"
        "https://cache.garnix.io/"
        "https://nix-community.cachix.org/"
        "https://msfjarvis.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "msfjarvis.cachix.org-1:/sKPgZblk/LgoOKtDgMTwvRuethILGkr/maOvZ6W11U="
      ];
      trusted-users = ["msfjarvis" "root"];
      extra-experimental-features = ["nix-command" "flakes"];
    };
  };
}
