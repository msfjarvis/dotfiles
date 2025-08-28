{ namespace, ... }:
{
  snowfallorg.user = {
    enable = true;
    name = "msfjarvis";
  };

  profiles.${namespace}.starship.server = true;
  nix.extraOptions = ''
    substituters = https://nix-cache.tiger-shark.ts.net/aarch64-linux https://cache.nixos.org
    trusted-public-keys = aarch64-linux:n1uEEJsd/qjPYB1G3jUEW1oyia8O9rTCJKpCLgPW2gM= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
    netrc-file = /home/msfjarvis/.config/nix/netrc
  '';

  home.stateVersion = "21.05";
}
