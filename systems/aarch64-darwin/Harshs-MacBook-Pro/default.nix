{pkgs, ...}: {
  users.users.msfjarvis = {
    name = "msfjarvis";
    home = "/Users/msfjarvis";
  };

  environment.variables = {
    LANG = "en_US.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    jarvis.adx
    awscli2
    coreutils
    jarvis.diffuse-bin
    jarvis.gdrive
    git-absorb
    hub
    jarvis.katbin
    maestro
    ninja
    openssh
    openssl
    jarvis.pidcat
    scrcpy
    jarvis.toml-cli
  ];

  programs.gnupg.agent.enable = true;
  programs.man.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
