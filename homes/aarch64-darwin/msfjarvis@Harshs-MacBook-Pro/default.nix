{ namespace, ... }:
{
  snowfallorg.user = {
    enable = true;
    name = "msfjarvis";
  };

  profiles.${namespace} = {
    ghostty.enable = true;
    opencode.enable = true;
  };

  home.stateVersion = "21.05";
}
