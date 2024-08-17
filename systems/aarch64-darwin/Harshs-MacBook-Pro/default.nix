{ pkgs, namespace, ... }:
{
  users.users.msfjarvis = {
    name = "msfjarvis";
    home = "/Users/msfjarvis";
  };

  environment.variables = {
    LANG = "en_US.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    pkgs.${namespace}.adx
    attic
    coreutils
    pkgs.${namespace}.diffuse-bin
    pkgs.${namespace}.gdrive
    git-absorb
    hub
    pkgs.${namespace}.katbin
    maestro
    nh
    ninja
    nix-output-monitor
    openssh
    openssl
    pkgs.${namespace}.pidcat
    scrcpy
  ];

  programs.gnupg.agent.enable = true;
  programs.man.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
