{ config, pkgs, ... }:

let
  customTarball = fetchTarball
    "https://github.com/msfjarvis/custom-nixpkgs/archive/c805935e4c674394315f4488d29fdc042965c622.tar.gz";
in {
  home.username = "msfjarvis";
  home.homeDirectory = "/home/msfjarvis";
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: { custom = import customTarball { }; };
  };

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
  };

  programs.git = {
    enable = true;
    ignores = [ ".envrc" "key.properties" "keystore.properties" "*.jks" ];
    includes = [{
      path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig";
    }];
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
      only = [ "system" "nix" "home_manager" ];
      set_title = false;
      cleanup = true;
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  home.packages = with pkgs; [
    bandwhich
    bat
    bottom
    cachix
    curl
    diff-so-fancy
    direnv
    diskus
    dos2unix
    custom.fclones
    fd
    ffmpeg
    figlet
    fzf
    hyperfine
    libwebp
    magic-wormhole
    meson
    micro
    mosh
    ncdu
    neofetch
    ninja
    patchelf
    procs
    python39
    python39Packages.poetry
    python39Packages.virtualenv
    ripgrep
    custom.rust-script
    sd
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
