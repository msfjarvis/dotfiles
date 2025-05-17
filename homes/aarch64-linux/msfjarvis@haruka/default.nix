_: {
  snowfallorg.user = {
    enable = true;
    name = "msfjarvis";
  };

  nix.extraOptions = ''
    substituters = https://nix-cache.tiger-shark.ts.net/aarch64-linux https://cache.nixos.org
    trusted-public-keys = aarch64-linux:czBXxHtNIDorynmG/2pRuFSENM+fnu0rgVkH+8I4niQ= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
    netrc-file = /home/msfjarvis/.config/nix/netrc
  '';

  home.stateVersion = "25.05";
}
