{ namespace, ... }:
{
  snowfallorg.user = {
    enable = true;
    name = "msfjarvis";
  };

  profiles.${namespace}.starship.server = true;

  home.stateVersion = "21.05";
}
