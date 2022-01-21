{ config, pkgs, ... }:

let
  customTarball = fetchTarball
    "https://github.com/msfjarvis/custom-nixpkgs/archive/671fe576214065f99f41157a0ec4386c80e50501.tar.gz";
  zig-overlay = fetchTarball
    "https://github.com/arqv/zig-overlay/archive/151d4bb403a86eac42ed53eae1cd64db247ce37f.tar.gz";

in {
  home.username = "msfjarvis";
  home.homeDirectory =
    if pkgs.stdenv.isLinux then "/home/msfjarvis" else "/Users/msfjarvis";
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      custom = import customTarball { };
      zigf = import zig-overlay { };
    };
  };
  nixpkgs.overlays = [ (import <rust-overlay>) ];

  fonts.fontconfig.enable = true;

  programs.aria2 = { enable = pkgs.stdenv.isLinux; };

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
    '' + pkgs.lib.optionalString pkgs.stdenv.isLinux ''
      # Source shell-init from my dotfiles
      source ${config.home.homeDirectory}/git-repos/dotfiles/shell-init
    '' + pkgs.lib.optionalString pkgs.stdenv.isDarwin ''
      # Source shell-init from my dotfiles
      source ${config.home.homeDirectory}/git-repos/dotfiles/darwin-init
      export BASH_SILENCE_DEPRECATION_WARNING=1
    '';
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
      pager = "bat";
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

  services.gpg-agent = {
    enable = pkgs.stdenv.isLinux;
    defaultCacheTtl = 600;
    pinentryFlavor = "gtk2";
  };

  services.password-store-sync = {
    enable = pkgs.stdenv.isLinux;
    frequency = "*-*-* *:00:00";
  };

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
    enable = pkgs.stdenv.isLinux;

    settings = {
      disable = [ "gnome_shell_extensions" "nix" "node" "sdkman" ];

      remote_topgrades = [ "backup" "ci" "oracle" ];

      remote_topgrade_path = "bin/topgrade";

      set_title = false;
      cleanup = true;
    };
  };

  programs.vscode = { enable = pkgs.stdenv.isLinux; };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  systemd.user.services.clipboard-substitutor = {
    Service = {
      Type = "simple";
      ExecStart =
        "${pkgs.custom.clipboard-substitutor}/bin/clipboard-substitutor";
    };
    Install = { WantedBy = [ "gnome-session-x11.target" ]; };
  };

  home.packages = with pkgs;
    [
      custom.adx
      bat
      bash
      custom.bundletool-bin
      cachix
      curl
      diff-so-fancy
      custom.diffuse-bin
      direnv
      diskus
      dos2unix
      fd
      fzf
      git-absorb
      git-quickfix
      custom.hcctl
      hub
      hyperfine
      (magic-wormhole.overrideAttrs
        (oldAttrs: { doCheck = !pkgs.stdenv.isDarwin; }))
      micro
      mosh
      ncdu
      neofetch
      nixfmt
      nvd
      oathToolkit
      custom.pidcat
      qrencode
      ripgrep
      rust-script
      scrcpy
      sd
      shellcheck
      shfmt
      unzip
      vivid
      zip
    ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
      act
      custom.adb-sync
      cargo-edit
      cargo-update
      ccache
      choose
      clang_12
      custom.clipboard-substitutor
      cmake
      cowsay
      dnscontrol
      fclones
      (rust-bin.selectLatestNightlyWith (toolchain:
        toolchain.default.override {
          extensions = [ "rust-src" "rustfmt-preview" ];
          targets = [ "x86_64-unknown-linux-musl" ];
        }))
      ffmpeg
      figlet
      custom.gdrive
      git-crypt
      glow
      hugo
      custom.jetbrains-mono-nerdfonts
      libwebp
      lolcat
      musl.dev
      nix-update
      nixpkgs-review
      openssl
      patchelf
      pkg-config
      python39
      python39Packages.poetry
      python39Packages.virtualenv
      xclip
      xdotool
      zigf."0.9.0"
      zls
    ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [ openssh ];

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
