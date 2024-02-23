{pkgs, ...}: {
  users.users.msfjarvis = {
    name = "msfjarvis";
    home = "/Users/msfjarvis";
  };

  environment.variables = {
    LANG = "en_US.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    adx
    awscli2
    coreutils
    diffuse-bin
    gdrive
    git-absorb
    hub
    katbin
    maestro
    ninja
    openssh
    openssl
    pidcat
    scrcpy
  ];

  programs.gnupg.agent.enable = true;
  programs.man.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
