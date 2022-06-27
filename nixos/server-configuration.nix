{ config, pkgs, ... }:

let
  customTarball = fetchTarball
    "https://github.com/msfjarvis/custom-nixpkgs/archive/4c020b5ce0d99fa12d448a5e3f79ce7cc512863c.tar.gz";
in {
  home.username = "msfjarvis";
  home.homeDirectory = "/home/msfjarvis";
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: { custom = import customTarball { }; };
  };

  programs.aria2 = { enable = true; };

  programs.bash = {
    enable = true;
    historySize = 1000;
    historyFile = "${config.home.homeDirectory}/.bash_history";
    historyFileSize = 10000;
    historyControl = [ "ignorespace" "erasedups" ];
    initExtra = ''
      # Load completions from system
      if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
      elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
      fi
      # Load completions from Git
      source ${pkgs.git}/share/bash-completion/completions/git
      # Source shell-init from my dotfiles
      source ${config.home.homeDirectory}/dotfiles/shell-init
    '';
  };

  programs.bat = {
    enable = true;
    config = { theme = "zenburn"; };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd -tf";
    defaultOptions = [ "--height 40%" ];
    enableBashIntegration = true;
    fileWidgetCommand = "fd -H";
    changeDirWidgetCommand = "fd -Htd";
    historyWidgetOptions = [ "--sort" "--exact" ];
  };

  programs.git = {
    enable = true;
    ignores = [ ".envrc" "key.properties" "keystore.properties" "*.jks" ];
    includes = [{ path = "${config.home.homeDirectory}/dotfiles/.gitconfig"; }];
  };

  programs.gpg = { enable = true; };

  programs.home-manager = { enable = true; };

  programs.htop = { enable = true; };

  programs.jq = { enable = true; };

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = false;
      git_branch.symbol = " ";
      git_status = {
        ahead = "";
        behind = "";
        diverged = "";
      };
      format = "$directory$git_branch$git_state$git_status➜ ";
    };
  };

  programs.topgrade = {
    enable = true;

    settings = {
      only = [ "bin" "cargo" "system" "micro" ];
      set_title = false;
      cleanup = true;
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  systemd.user.services.nix-collect-garbage = {
    Unit = { Description = "Nix garbage collection"; };

    Service = {
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      ExecStart = toString (pkgs.writeShellScript "nix-garbage-collection" ''
        ${pkgs.nix}/bin/nix-collect-garbage -d
      '');
    };
  };

  systemd.user.timers.nix-collect-garbage = {
    Unit = { Description = "Nix periodic garbage collection"; };

    Timer = {
      Unit = "nix-collect-garbage.service";
      OnCalendar = "*-*-* *:00:00";
      Persistent = true;
    };

    Install = { WantedBy = [ "timers.target" ]; };
  };

  home.packages = with pkgs; [
    bat
    cachix
    curl
    diff-so-fancy
    diskus
    dos2unix
    fd
    ffmpeg
    custom.healthchecks-monitor
    custom.katbin
    magic-wormhole
    micro
    mosh
    ncdu_2
    neofetch
    nvd
    patchelf
    python39
    python39Packages.poetry
    python39Packages.virtualenv
    ripgrep
    shellcheck
    shfmt
    vivid
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
