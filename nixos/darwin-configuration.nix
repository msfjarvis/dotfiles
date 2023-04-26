{
  config,
  pkgs,
  ...
}: {
  users.users.msfjarvis = {
    name = "Harsh Shandilya";
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

  home-manager.useGlobalPkgs = true;
  home-manager.users.msfjarvis = {pkgs, ...}: {
    programs.bash = {
      enable = true;
      historySize = 1000;
      historyFile = "/Users/msfjarvis/.bash_history";
      historyFileSize = 10000;
      historyControl = ["ignorespace" "erasedups"];
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
      config = {theme = "zenburn";};
    };

    programs.browserpass = {
      enable = true;
      browsers = ["chrome"];
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
      defaultOptions = ["--height 40%"];
      enableBashIntegration = true;
      fileWidgetCommand = "fd -H";
      changeDirWidgetCommand = "fd -Htd";
      historyWidgetOptions = ["--sort" "--exact"];
    };

    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "https";
        editor = "micro";
        prompt = "enabled";
        aliases = {co = "pr checkout";};
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
        ".DS_Store"
      ];
      includes = [
        {path = "/Users/msfjarvis/git-repos/dotfiles/.gitconfig";}
        {
          path = "/Users/msfjarvis/git-repos/dotfiles/.gitconfig-work";
        }
      ];
    };

    programs.gpg = {enable = true;};

    programs.home-manager = {enable = true;};

    programs.jq = {enable = true;};

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

    programs.password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [exts.pass-audit exts.pass-genphrase exts.pass-otp exts.pass-update]);
    };

    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      settings = {
        add_newline = false;
        aws.disabled = true;
        azure.disabled = true;
        battery.disabled = true;
        buf.disabled = true;
        bun.disabled = true;
        c.disabled = true;
        character = {
          disabled = false;
          error_symbol = ''

            [➜](bold red)'';
          success_symbol = ''

            [➜](bold green)'';
        };
        cmake.disabled = true;
        cmd_duration.disabled = true;
        cobol.disabled = true;
        conda.disabled = true;
        container.disabled = true;
        crystal.disabled = true;
        daml.disabled = true;
        dart.disabled = true;
        deno.disabled = true;
        docker_context.disabled = true;
        dotnet.disabled = true;
        elixir.disabled = true;
        elm.disabled = true;
        env_var.disabled = true;
        erlang.disabled = true;
        fennel.disabled = true;
        fill.disabled = true;
        fossil_branch.disabled = true;
        gcloud.disabled = true;
        git_branch = {
          disabled = false;
          symbol = " ";
        };
        git_commit.disabled = false;
        git_state.disabled = false;
        git_metrics.disabled = false;
        git_status = {
          disabled = false;
          ahead = "";
          behind = "";
          diverged = "";
        };
        golang.disabled = true;
        guix_shell.disabled = true;
        gradle.disabled = false;
        haskell.disabled = true;
        haxe.disabled = true;
        helm.disabled = true;
        hg_branch.disabled = true;
        hostname.disabled = true;
        java.disabled = false;
        jobs.disabled = true;
        julia.disabled = true;
        kotlin.disabled = true;
        kubernetes.disabled = true;
        line_break.disabled = true;
        localip.disabled = true;
        lua.disabled = true;
        memory_usage.disabled = true;
        meson.disabled = true;
        nim.disabled = true;
        nix_shell.disabled = true;
        nodejs.disabled = true;
        ocaml.disabled = true;
        opa.disabled = true;
        openstack.disabled = true;
        os.disabled = true;
        package.disabled = false;
        perl.disabled = true;
        php.disabled = true;
        pijul_channel.disabled = true;
        pulumi.disabled = true;
        purescript.disabled = true;
        python.disabled = false;
        rlang.disabled = true;
        raku.disabled = true;
        red.disabled = true;
        ruby.disabled = true;
        rust.disabled = false;
        scala.disabled = true;
        shell.disabled = true;
        shlvl.disabled = true;
        singularity.disabled = true;
        spack.disabled = true;
        status.disabled = true;
        sudo.disabled = true;
        swift.disabled = true;
        terraform.disabled = true;
        time.disabled = true;
        vagrant.disabled = true;
        vlang.disabled = true;
        vcsh.disabled = true;
        zig.disabled = true;
      };
    };

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    home.stateVersion = "21.05";
  };

  homebrew = {
    enable = true;
    brews = [
      "cocoapods"
      "carthage"
      "ruby"
    ];
  };

  environment.systemPackages = with pkgs; [
    custom.adx
    alejandra
    cachix
    comma
    coreutils
    curl
    delta
    dasel
    custom.diffuse-bin
    direnv
    diskus
    dos2unix
    fd
    flock
    fzf
    custom.gdrive
    gradle-completion
    git-absorb
    git-quickfix
    hub
    custom.katbin
    mosh
    nil
    nvd
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
