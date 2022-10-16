{ config, pkgs, ... }:

let
  customTarball = fetchTarball
    "https://github.com/msfjarvis/custom-nixpkgs/archive/b844ee4d66d4fde99d357b09568182c6b0a3338e.tar.gz";
in {
  home.username = "msfjarvis";
  home.homeDirectory = "/home/msfjarvis";
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: { custom = import customTarball { }; };
  };

  fonts.fontconfig.enable = true;

  home.file.".imwheelrc".text = ''
    ".*"
    None,      Up,   Button4, 3
    None,      Down, Button5, 3
    Control_L, Up,   Control_L|Button4
    Control_L, Down, Control_L|Button5
    Shift_L,   Up,   Shift_L|Button4
    Shift_L,   Down, Shift_L|Button5
  '';

  home.file.".local/share/applications/vscode.desktop".text = ''
    #!/usr/bin/env xdg-open
    [Desktop Entry]
    Version=1.0
    Type=Application
    Terminal=false
    Icon=${pkgs.vscode}/lib/vscode/resources/app/resources/linux/code.png
    Exec=${pkgs.vscode}/bin/code
    Name=VSCode
  '';

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
      # Load completions from scrcpy
      source ${pkgs.scrcpy}/share/bash-completion/completions/scrcpy
      # Source shell-init from my dotfiles
      source ${config.home.homeDirectory}/git-repos/dotfiles/shell-init
    '';
    shellOptions = [
      # Append to history file rather than replacing it.
      "histappend"

      # check the window size after each command and, if
      # necessary, update the values of LINES and COLUMNS.
      "checkwinsize"

      # Extended globbing.
      "extglob"
      "globstar"

      # Warn if closing shell with running jobs.
      "checkjobs"
    ];
  };

  programs.bat = {
    enable = true;
    config = { theme = "zenburn"; };
  };

  programs.bottom = { enable = true; };

  programs.browserpass = {
    enable = true;
    browsers = [ "chrome" ];
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
    stdlib = ''
      # iterate on pairs of [candidate] [version] and invoke `sdk use` on each of them 
      use_sdk() {
        [[ -s "''${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "''${SDKMAN_DIR}/bin/sdkman-init.sh"

        while (( "$#" >= 2 )); do
          local candidate=''${1}
          local candidate_version=''${2}
          SDKMAN_OFFLINE_MODE=true sdk use ''${candidate} ''${candidate_version}

          shift 2
        done
      }
    '';
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

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      editor = "micro";
      prompt = "enabled";
      aliases = { co = "pr checkout"; };
      browser = "google-chrome-stable";
    };
  };

  programs.git = {
    enable = true;
    ignores = [
      ".envrc"
      "key.properties"
      "keystore.properties"
      "*.jks"
      ".direnv/"
      "fleet.toml"
    ];
    includes = [
      { path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig"; }
      {
        path =
          "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig-auth";
      }
    ];
  };

  programs.home-manager = { enable = true; };

  programs.htop = { enable = true; };

  programs.jq = { enable = true; };

  programs.micro = {
    enable = true;
    settings = {
      colorscheme = "dracula";
      softwrap = true;
      wordwrap = true;
    };
  };

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.password-store = { enable = true; };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = false;
      character = {
        error_symbol = ''

          [➜](bold red)'';
        success_symbol = ''

          [➜](bold green)'';
      };
      git_branch.symbol = " ";
      git_status = {
        ahead = "";
        behind = "";
        diverged = "";
      };
      java.symbol = " ";
      rust.symbol = " ";
      aws.disabled = true;
      battery.disabled = true;
      cmake.disabled = true;
      cmd_duration.disabled = true;
      conda.disabled = true;
      crystal.disabled = true;
      dart.disabled = true;
      docker_context.disabled = true;
      dotnet.disabled = true;
      elixir.disabled = true;
      elm.disabled = true;
      env_var.disabled = true;
      erlang.disabled = true;
      golang.disabled = true;
      helm.disabled = true;
      hg_branch.disabled = true;
      hostname.disabled = true;
      jobs.disabled = true;
      julia.disabled = true;
      kotlin.disabled = true;
      kubernetes.disabled = true;
      line_break.disabled = true;
      memory_usage.disabled = true;
      nodejs.disabled = true;
      perl.disabled = true;
      ruby.disabled = true;
      php.disabled = true;
      terraform.disabled = true;
      shlvl.disabled = true;
      singularity.disabled = true;
      status.disabled = true;
      swift.disabled = true;
      vagrant.disabled = true;
      vlang.disabled = true;
    };
  };

  programs.topgrade = {
    enable = true;

    settings = {
      disable =
        [ "gnome_shell_extensions" "home_manager" "nix" "node" "sdkman" ];

      remote_topgrades = [ "ci" ];

      remote_topgrade_path = "bin/topgrade";

      set_title = false;
      cleanup = true;
    };
  };

  programs.vscode = { enable = true; };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 600;
    pinentryFlavor = "gtk2";
  };

  services.password-store-sync = {
    enable = true;
    frequency = "*-*-* *:00:00";
  };

  systemd.user.services.file-collector = {
    Unit = {
      Description = "systemd service for file-collector";
      After = "local-fs.target";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.custom.file-collector}/bin/file-collector";
      Restart = "on-failure";
      RestartSec = 3;
      Environment = "PATH=${pkgs.watchman}/bin";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };

  systemd.user.services.clipboard-substitutor = {
    Unit = { Description = "systemd service for clipboard-substitutor"; };
    Service = {
      Type = "simple";
      ExecStart =
        "${pkgs.custom.clipboard-substitutor}/bin/clipboard-substitutor";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = { WantedBy = [ "default.target" ]; };
  };

  systemd.user.services.imwheel = {
    Unit = {
      Description = "systemd service for imwheel";
      Wants = "display-manager.service";
      After = "display-manager.service";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.imwheel}/bin/imwheel -d";
      ExecStop = "/usr/bin/pkill imwheel";
      RemainAfterExit = "yes";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = { WantedBy = [ "default.target" ]; };
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
    custom.adb-sync
    custom.adx
    bat
    cachix
    choose
    comma
    curl
    dasel
    diff-so-fancy
    custom.diffuse-bin
    diskus
    dos2unix
    duf
    fclones
    fd
    ferium
    fzf
    custom.gdrive
    git-absorb
    git-crypt
    git-quickfix
    custom.hcctl
    helix
    hub
    hyperfine
    imwheel
    (nerdfonts.override {
      fonts = [ "CascadiaCode" "FiraCode" "Inconsolata" "JetBrainsMono" ];
    })
    just
    custom.katbin
    mcfly
    mold
    mosh
    ncdu_2
    neofetch
    niv
    nixfmt
    nix-update
    nixpkgs-review
    nvd
    oathToolkit
    openssl
    patchelf
    custom.pidcat
    procs
    qrencode
    ripgrep
    scrcpy
    sd
    shellcheck
    shfmt
    silicon
    unzip
    vivid
    watchman
    custom.when
    xclip
    xdotool
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
