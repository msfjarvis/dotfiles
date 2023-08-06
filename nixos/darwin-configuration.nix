{pkgs, ...}: let
  defaultPkgs = import ./modules/default-packages.nix;
in {
  users.users.msfjarvis = {
    name = "msfjarvis";
    home = "/Users/msfjarvis";
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      (nerdfonts.override {
        fonts = ["CascadiaCode" "FiraCode" "Inconsolata" "JetBrainsMono"];
      })
    ];
  };

  homebrew = {
    enable = true;
    brews = [
      "cocoapods"
      "carthage"
      "ruby"
      "JakeWharton/repo/dependency-watch"
    ];
    taps = [
      "JakeWharton/repo"
    ];
  };

  nix = {
    settings = {
      trusted-substituters = [
        "https://cache.nixos.org/"
        "https://cache.garnix.io/"
        "https://nix-community.cachix.org/"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = ["msfjarvis" "root"];
    };
  };

  environment.systemPackages = with pkgs;
    [
      adx
      coreutils
      dasel
      diffuse-bin
      flock
      gdrive
      gradle-completion
      git-absorb
      go
      hub
      katbin
      nvd
      openssh
      openssl
      pidcat
    ]
    ++ (defaultPkgs pkgs);

  programs.gnupg.agent.enable = true;
  programs.man.enable = true;
  programs.nix-index.enable = true;

  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  home-manager.useGlobalPkgs = true;
  home-manager.users.msfjarvis = {pkgs, ...}: {
    imports = [
      ./modules/vscode/home-manager.nix
      ./home-manager-common.nix
    ];

    programs.bash = {
      initExtra = ''
        # Load completions from system
        if [ -f /usr/share/bash-completion/bash_completion ]; then
          . /usr/share/bash-completion/bash_completion
        elif [ -f /etc/bash_completion ]; then
          . /etc/bash_completion
        fi
        # Source shell-init from my dotfiles
        source /Users/msfjarvis/git-repos/dotfiles/darwin-init
        export BASH_SILENCE_DEPRECATION_WARNING=1
      '';
    };

    programs.browserpass = {
      enable = true;
      browsers = ["chrome"];
    };

    programs.git = {
      includes = [
        {path = "/Users/msfjarvis/git-repos/dotfiles/.gitconfig";}
        {
          path = "/Users/msfjarvis/git-repos/dotfiles/.gitconfig-work";
        }
      ];
    };

    programs.micro = {
      enable = true;
      settings = {
        colorscheme = "dracula";
        softwrap = true;
        wordwrap = true;
      };
    };

    programs.password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [exts.pass-audit exts.pass-genphrase exts.pass-otp exts.pass-update]);
    };

    # home-manager uses nmd to build these which triggers a Nix bug
    # https://github.com/NixOS/nix/issues/8485
    manual.manpages.enable = false;
  };
}
