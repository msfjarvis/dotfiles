{
  config,
  pkgs,
  ...
}: {
  home.username = "msfjarvis";
  home.homeDirectory = "/home/msfjarvis";
  targets.genericLinux.enable = true;

  programs.aria2 = {enable = true;};

  programs.bash = {
    enable = true;
    historySize = 1000;
    historyFile = "${config.home.homeDirectory}/.bash_history";
    historyFileSize = 10000;
    historyControl = ["ignorespace" "erasedups"];
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
      # Source shell-init from my dotfiles
      source ${config.home.homeDirectory}/dotfiles/shell-init
      # _byobu_sourced=1 . /usr/bin/byobu-launch 2>/dev/null || true
    '';
  };

  programs.bat = {
    enable = true;
    config = {theme = "zenburn";};
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
    defaultOptions = ["--height 40%"];
    enableBashIntegration = true;
    fileWidgetCommand = "fd -H";
    changeDirWidgetCommand = "fd -Htd";
    historyWidgetOptions = ["--sort" "--exact"];
  };

  programs.git = {
    enable = true;
    ignores = [".envrc" "key.properties" "keystore.properties" "*.jks"];
    includes = [{path = "${config.home.homeDirectory}/dotfiles/.gitconfig";}];
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

  programs.gpg = {enable = true;};

  programs.home-manager = {enable = true;};

  programs.htop = {enable = true;};

  programs.jq = {enable = true;};

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_state$git_status➜ ";
      aws.disabled = true;
      azure.disabled = true;
      battery.disabled = true;
      buf.disabled = true;
      bun.disabled = true;
      c.disabled = true;
      character.disabled = true;
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
      nix_shell.disabled = false;
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

  programs.topgrade = {
    enable = true;
    package = pkgs.custom.topgrade-og;

    settings = {
      only = ["bin" "system" "micro"];
      set_title = false;
      cleanup = true;
      commands = {"Cargo" = "cargo install-update --all";};
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  systemd.user.services.optimise-nix-store = {
    Unit = {Description = "nix store maintenance";};

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
    Unit = {Description = "nix store maintenance";};
    Timer = {OnCalendar = "weekly";};
    Install = {WantedBy = ["timers.target"];};
  };

  home.packages = with pkgs; [
    alejandra
    cachix
    custom.cargo-dist
    cargo-wipe
    comma
    curl
    delta
    diskus
    dos2unix
    fd
    flyctl
    custom.healthchecks-monitor
    helix
    hub
    git-absorb
    custom.katbin
    megatools
    micro
    mosh
    ncdu_2
    nil
    nix
    nix-init
    nix-update
    nixpkgs-review
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
