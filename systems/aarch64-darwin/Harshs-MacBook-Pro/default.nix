{ pkgs, namespace, ... }:
{
  users.users.msfjarvis = {
    name = "msfjarvis";
    home = "/Users/msfjarvis";
  };
  system.primaryUser = "msfjarvis";

  environment.variables = {
    LANG = "en_US.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    pkgs.${namespace}.adbear
    pkgs.${namespace}.adx
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
    nixd
    openssh
    openssl
    pkgs.${namespace}.pidcat
    scrcpy
  ];

  environment.pathsToLink = [
    "Applications"
    "/bin"
    "/lib"
    "/man"
    "/share"
  ];

  homebrew = {
    brews = [
      "gnu-sed"
      "mpv"
      "spicetify-cli"
    ];
    casks = [
      "alt-tab"
      "obsidian"
      "raycast"
      "rectangle"
      "spotify"
      "zed"
    ];
    taps = [ ];
  };

  programs.gnupg.agent.enable = true;
  programs.man.enable = true;

  # Allow sudo with Touch ID
  security.pam.services.sudo_local.touchIdAuth = true;

  security.sudo.extraConfig = ''
    Defaults    env_keep += "TERMINFO"
  '';

  ids.gids.nixbld = 350;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
