{ config, pkgs, ... }:

let customTarball = fetchTarball
  "https://github.com/msfjarvis/custom-nixpkgs/archive/957d24bf32ce.tar.gz";
in
{
  home.username = "msfjarvis";
  home.homeDirectory = if pkgs.stdenv.isLinux then "/home/msfjarvis" else "/Users/msfjarvis";
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      custom = import customTarball { };
    };
  };

  programs.aria2 = {
    enable = pkgs.stdenv.isLinux;
  };

  programs.bash = {
    enable = true;
    historySize = 1000;
    historyFile = "${config.home.homeDirectory}/.bash_history";
    historyFileSize = 10000;
    historyControl = [
      "ignorespace"
      "erasedups"
    ];
    initExtra = ''
      # Load completions from system
      if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
      elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
      fi
      # Load completions from Git
      source ${pkgs.git}/share/bash-completion/completions/git
    '' + pkgs.lib.optionalString pkgs.stdenv.isLinux ''
      # Source shell-init from my dotfiles
      source ${config.home.homeDirectory}/git-repos/dotfiles/shell-init
    '' + pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
      # Source shell-init from my dotfiles
      source ${config.home.homeDirectory}/git-repos/dotfiles/darwin-init
    '';
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "zenburn";
    };
  };

  programs.broot = {
    enable = pkgs.stdenv.isLinux;
    enableBashIntegration = true;
  };

  programs.browserpass = {
    enable = true;
    browsers = [
      "chrome"
    ];
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd -tf";
    defaultOptions = [
      "--height 40%"
    ];
    enableBashIntegration = true;
  };

  programs.git = {
    enable = true;
    ignores = [
      ".envrc"
      "key.properties"
      "keystore.properties"
      "*.jks"
    ];
    includes = [
      { path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig"; }
    ];
  };

  programs.gpg = {
    enable = true;
  };

  programs.home-manager = {
    enable = true;
  };

  programs.htop = {
    enable = true;
  };

  programs.jq = {
    enable = true;
  };

  programs.lsd = {
    enable = false;
    enableAliases = false;
  };

  programs.password-store = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = pkgs.lib.mkMerge [
      {
        add_newline = false;
        character = {
          error_symbol = "➜";
          success_symbol = "➜";
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
        haskell.disabled = true;
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
      }
    ];
  };

  programs.topgrade = {
    enable = true;

    settings = pkgs.lib.mkMerge [
      {
        disable = [
          "sdkman"
          "flutter"
          "node"
          "nix"
          "home_manager"
        ];

        remote_topgrades = [
          "backup"
          "ci"
        ];

        remote_topgrade_path = "bin/topgrade";
      }

      {
        set_title = false;
        cleanup = true;

        commands = {
          "Purge unused APT packages" = "sudo apt autoremove";
        };
      }
    ];
  };

  programs.vscode = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  home.packages = with pkgs; [
    bat
    bottom
    cachix
    curl
    diff-so-fancy
    custom.diffuse
    direnv
    diskus
    dos2unix
    fd
    fzf
    gitAndTools.gh
    gitAndTools.git-absorb
    custom.git-quickfix
    gitAndTools.hub
    magic-wormhole
    micro
    mosh
    custom.natls
    ncdu
    neofetch
    nixfmt
    nixpkgs-fmt
    oathToolkit
    custom.pidcat
    qrencode
    ripgrep
    shellcheck
    shfmt
    tokei
    vivid
  ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
    act
    custom.adb-sync
    custom.adx
    asciinema
    bandwhich
    cargo-edit
    cargo-update
    ccache
    choose
    cmake
    cowsay
    dnscontrol
    droidcam
    espanso
    custom.fclones
    ffmpeg
    figlet
    gitAndTools.git-crypt
    glow
    go
    custom.grit
    gron
    custom.himalaya
    hugo
    hyperfine
    kazam
    libwebp
    lolcat
    custom.lychee
    meson
    ninja
    nodejs-14_x
    patchelf
    procs
    python38
    python38Packages.poetry
    python38Packages.virtualenv
    scrcpy
    sd
    xclip
    xdotool
  ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
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
