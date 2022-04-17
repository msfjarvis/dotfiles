{ config, pkgs, ... }:

let
  customTarball = fetchTarball
    "https://github.com/msfjarvis/custom-nixpkgs/archive/54791342266a888a95225d49c4df4b55ebca52ec.tar.gz";
in {
  home.username = "msfjarvis";
  home.homeDirectory = "/home/msfjarvis";
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: { custom = import customTarball { }; };
  };
  nixpkgs.overlays = [ (import <rust-overlay>) ];

  fonts.fontconfig.enable = true;

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
    ignores =
      [ ".envrc" "key.properties" "keystore.properties" "*.jks" ".direnv/" ];
    includes = [
      { path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig"; }
      {
        path =
          "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig-auth";
      }
    ];
  };

  programs.gpg = { enable = true; };

  programs.home-manager = { enable = true; };

  programs.htop = { enable = true; };

  programs.jq = { enable = true; };

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
      disable = [ "gnome_shell_extensions" "nix" "node" "sdkman" ];

      remote_topgrades = [ "backup" "ci" ];

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

  systemd.user.services.clipboard-substitutor = {
    Unit = { Description = "SystemD service for clipboard-substitutor"; };
    Service = {
      Type = "simple";
      ExecStart =
        "${pkgs.custom.clipboard-substitutor}/bin/clipboard-substitutor";
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
    custom.bundletool-bin
    cachix
    cargo-deb
    cargo-depgraph
    cargo-edit
    cargo-release
    cargo-update
    choose
    clang_13
    custom.clipboard-substitutor
    cowsay
    curl
    diff-so-fancy
    custom.diffuse-bin
    direnv
    diskus
    dos2unix
    duf
    fclones
    fd
    fzf
    custom.gdrive
    git-absorb
    git-crypt
    git-quickfix
    custom.hcctl
    hub
    hyperfine
    custom.jetbrains-mono-nerdfonts
    mcfly
    micro
    mold
    mosh
    musl.dev
    ncdu
    neofetch
    nixfmt
    nix-update
    nixpkgs-review
    nvd
    oathToolkit
    openssl
    patchelf
    custom.pidcat
    pkg-config
    procs
    python39
    python39Packages.poetry
    python39Packages.virtualenv
    qrencode
    ripgrep
    (rust-bin.selectLatestNightlyWith (toolchain:
      toolchain.default.override {
        extensions = [ "rust-src" "rustfmt-preview" "llvm-tools-preview" ];
        targets = pkgs.lib.optionals pkgs.stdenv.isLinux
          [ "x86_64-unknown-linux-musl" ];
      }))
    scrcpy
    sd
    shellcheck
    shfmt
    unzip
    vivid
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
