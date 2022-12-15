{ config, pkgs, ... }: {

  home.username = "ubuntu";
  home.homeDirectory = "/home/ubuntu";

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
      if [ -d ${config.home.homeDirectory}/android-sdk ]; then
        export ANDROID_SDK_ROOT="${config.home.homeDirectory}/android-sdk"
      fi
      # Load completions from Git
      source ${pkgs.git}/share/bash-completion/completions/git
      # Source shell-init from my dotfiles
      source ${config.home.homeDirectory}/dotfiles/shell-init
      _byobu_sourced=1 . /usr/bin/byobu-launch 2>/dev/null || true
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

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      editor = "micro";
      prompt = "enabled";
      aliases = { co = "pr checkout"; };
    };
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
    package = pkgs.custom.topgrade-og;

    settings = {
      only = [ "bin" "system" "micro" ];
      set_title = false;
      cleanup = true;
      commands = { "Cargo" = "cargo install-update --all"; };
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  systemd.user.services.optimise-nix-store = {
    Unit = { Description = "nix store maintenance"; };

    Service = {
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      ExecStart = toString (pkgs.writeShellScript "nix-optimise-store" ''
        ${pkgs.nix}/bin/nix-collect-garbage -d
        ${pkgs.nix}/bin/nix store gc
        ${pkgs.nix}/bin/nix store optimise
      '');
    };
  };

  systemd.user.timers.optimise-nix-store = {
    Unit = { Description = "nix store maintenance"; };
    Timer = { OnCalendar = "hourly"; };
    Install = { WantedBy = [ "timers.target" ]; };
  };

  systemd.user.services.nix-index-database = {
    Unit = { Description = "nix-index database cache updater"; };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "nix-index-database-fetch.sh" ''
        set -exuo pipefail
        PATH=${pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.wget ]};
        XDG_CACHE_HOME=${config.home.homeDirectory}/.cache
        filename="index-$(uname -m)-$(uname | tr '[:upper:]' '[:lower:]')"
        mkdir -p "$XDG_CACHE_HOME/nix-index"
        cd "$XDG_CACHE_HOME/nix-index"
        wget -nv -N https://github.com/Mic92/nix-index-database/releases/latest/download/"$filename"
        ln -f "$filename" files
      ''}";
    };
  };

  systemd.user.timers.nix-index-database = {
    Unit = { Description = "Update the nix-index database cache"; };
    Timer = { OnCalendar = "daily"; };
    Install = { WantedBy = [ "timers.target" ]; };
  };

  systemd.user.services.linkleaner = {
    Unit = {
      Description =
        "Telegram bot to improve link previews of social media posts";
      After = "network.target";
    };
    Service = {
      Type = "simple";
      EnvironmentFile = "${config.home.homeDirectory}/linkleaner.config";
      ExecStart = "${pkgs.custom.linkleaner}/bin/linkleaner";
      Restart = "on-failure";
      RestartSec = 3;
      TimeoutStopSec = "10s";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };

  home.packages = with pkgs; [
    bat
    cachix
    comma
    curl
    delta
    diskus
    dos2unix
    fd
    ffmpeg
    flyctl
    custom.healthchecks-monitor
    hub
    just
    custom.katbin
    micro
    mosh
    ncdu_2
    nix-update
    nixfmt
    neofetch
    nvd
    ripgrep
    sd
    shellcheck
    shfmt
    unzip
    vivid
    zip
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
