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
    pkgs.${namespace}.adbear
    pkgs.${namespace}.adx
    attic-client
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

  environment.pathsToLink = [
    "Applications"
    "/bin"
    "/lib"
    "/man"
    "/share"
  ];

  nix.linux-builder = {
    enable = true;
    maxJobs = 4;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };

  programs.gnupg.agent.enable = true;
  programs.man.enable = true;

  # Allow sudo with Touch ID
  security.pam.enableSudoTouchIdAuth = true;

  system.activationScripts = {
    # https://github.com/ryan4yin/nix-darwin-kickstarter/blob/f79b4d4cbd9c8c2ea56b6e5016131ff2179d3775/minimal/modules/system.nix#L14-L19
    postUserActivation.text = ''
      killall Dock
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
  };

  security.sudo.extraConfig = ''
    Defaults    env_keep += "TERMINFO"
  '';

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
