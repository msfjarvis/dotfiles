{ namespace, ... }:
{
  snowfallorg.user = {
    enable = true;
    name = "msfjarvis";
  };

  profiles.${namespace}.vscode.enable = true;

  home.stateVersion = "21.05";
}
