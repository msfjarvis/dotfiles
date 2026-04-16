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
    bun
    coreutils
    pkgs.${namespace}.diffuse-bin
    flock
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
    pkgs.${namespace}.pi-coding-agent
    pkgs.${namespace}.pidcat
    scrcpy
    pkgs.${namespace}.weave
    yaml-language-server
  ];

  environment.pathsToLink = [
    "Applications"
    "/bin"
    "/lib"
    "/man"
    "/share"
  ];

  homebrew = {
    caskArgs.no_quarantine = null;
    brews = [
      "static-var/tap/build-brief"
      "github-mcp-server"
      "gnu-sed"
      "pinentry-mac"
      "rtk"
      "sdkman/tap/sdkman-cli"
      "spicetify-cli"
    ];
    casks = [
      "alt-tab"
      "betterdisplay"
      "jetbrains-toolbox"
      "keepingyouawake"
      "obsidian"
      "orbstack"
      "raycast"
      "rectangle"
      "spotify"
      "tailscale-app"
      "telegram"
      "zed"
    ];
    taps = [
      "sdkman/tap"
      "static-var/tap"
    ];
  };

  programs.gnupg.agent.enable = true;
  programs.man.enable = true;

  # Allow sudo with Touch ID
  security.pam.services.sudo_local.touchIdAuth = true;

  security.sudo.extraConfig = ''
    Defaults    env_keep += "TERMINFO"
  '';

  ids.gids.nixbld = 350;

  system.activationScripts.postActivation.text = ''
    # Install Gradle and OpenJDK via sdkman if not already installed
    PRIMARY_USER_HOME="/Users/msfjarvis"
    export SDKMAN_DIR="$PRIMARY_USER_HOME/.sdkman"

    if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
      # Disable bash completion to avoid errors in non-interactive context
      BASH_COMPLETION_COMPAT_DIR=/dev/null
      export BASH_COMPLETION_COMPAT_DIR
      # shellcheck source=/dev/null
      source "$SDKMAN_DIR/bin/sdkman-init.sh" 2>/dev/null || true
      
      if ! sdk list gradle 2>/dev/null | grep -q "^>"; then
        sdk install gradle
      fi
      
      if ! sdk list java 2>/dev/null | grep -q "^>"; then
        sdk install java
      fi
    fi
  '';

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
