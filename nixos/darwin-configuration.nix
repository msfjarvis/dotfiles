{ config, pkgs, ... }:
let
  customTarball = fetchTarball
    "https://github.com/msfjarvis/custom-nixpkgs/archive/c671640742cc2c601f0b3adffb45069ad73d2149.tar.gz";

in {

  imports = [ <home-manager/nix-darwin> ];

  users.users.msfjarvis = {
    name = "Harsh Shandilya";
    home = "/Users/msfjarvis";
  };

  nixpkgs.config = {
    packageOverrides = pkgs: { custom = import customTarball { }; };
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users.msfjarvis = { pkgs, ... }: {
    programs.bash = {
      enable = true;
      historySize = 1000;
      historyFile = "/Users/msfjarvis/.bash_history";
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
        source /Users/msfjarvis/git-repos/dotfiles/darwin-init
        export BASH_SILENCE_DEPRECATION_WARNING=1
      '';
      shellOptions = [
        # Append to history file rather than replacing it.
        "histappend"

        # check the window size after each command and, if
        # necessary, update the values of LINES and COLUMNS.
        "checkwinsize"

        # Extended globbing.
        "extglob"
      ];
    };

    programs.bat = {
      enable = true;
      config = { theme = "zenburn"; };
    };

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
      };
    };

    programs.git = {
      enable = true;
      ignores =
        [ ".envrc" "key.properties" "keystore.properties" "*.jks" ".direnv/" ];
      includes = [
        { path = "/Users/msfjarvis/git-repos/dotfiles/.gitconfig"; }
        { path = "/Users/msfjarvis/git-repos/dotfiles/.gitconfig-auth"; }
      ];
    };

    programs.home-manager = { enable = true; };

    programs.jq = { enable = true; };

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

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
  };

  environment.systemPackages = with pkgs; [
    custom.adx
    curl
    diff-so-fancy
    cachix
    comma
    dasel
    custom.diffuse-bin
    direnv
    diskus
    fd
    fzf
    custom.fsrx
    custom.gdrive
    git-absorb
    git-quickfix
    hub
    hyperfine
    just
    custom.katbin
    micro
    mosh
    nixfmt
    oathToolkit
    openssh
    openssl
    custom.pidcat
    ripgrep
    sd
    shellcheck
    shfmt
    unzip
    vivid
    zip
  ];

  programs.gnupg.agent.enable = true;
  programs.man.enable = true;
  programs.nix-index.enable = true;

  services.nix-daemon.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
