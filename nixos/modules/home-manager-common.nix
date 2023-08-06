{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.bat = {
    enable = lib.mkDefault true;
    config = lib.mkDefault {theme = "zenburn";};
  };

  programs.bash = {
    enable = lib.mkDefault true;
    historySize = lib.mkDefault 1000;
    historyFile = lib.mkDefault "${config.home.homeDirectory}/.bash_history";
    historyFileSize = lib.mkDefault 10000;
    historyControl = lib.mkDefault ["ignorespace" "erasedups"];
    shellOptions = lib.mkDefault [
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

  programs.bottom = {enable = lib.mkDefault true;};

  programs.direnv = {
    enable = lib.mkDefault true;
    enableBashIntegration = lib.mkDefault true;
    nix-direnv.enable = lib.mkDefault true;
  };

  programs.fzf = {
    enable = lib.mkDefault true;
    defaultCommand = lib.mkDefault "fd -tf";
    defaultOptions = lib.mkDefault ["--height 40%"];
    enableBashIntegration = lib.mkDefault true;
    fileWidgetCommand = lib.mkDefault "fd -H";
    changeDirWidgetCommand = lib.mkDefault "fd -Htd";
    historyWidgetOptions = lib.mkDefault ["--sort" "--exact"];
  };

  programs.gh = {
    enable = lib.mkDefault true;
    settings = {
      git_protocol = lib.mkDefault "https";
      editor = lib.mkDefault "micro";
      prompt = lib.mkDefault "enabled";
      aliases = lib.mkDefault {co = "pr checkout";};
    };
  };

  programs.git = {
    enable = lib.mkDefault true;
    ignores = lib.mkDefault [
      ".envrc"
      "key.properties"
      "keystore.properties"
      "*.jks"
      ".direnv/"
      "fleet.toml"
      ".DS_Store"
    ];
  };

  programs.gpg = {enable = lib.mkDefault true;};

  programs.home-manager = {enable = lib.mkDefault true;};

  programs.jq = {enable = lib.mkDefault true;};

  programs.lsd = {
    enable = lib.mkDefault true;
    enableAliases = lib.mkDefault true;
  };

  programs.nix-index = {
    enable = lib.mkDefault true;
    enableBashIntegration = lib.mkDefault true;
  };

  programs.starship = {
    enable = lib.mkDefault true;
    enableBashIntegration = lib.mkDefault true;
    settings = {
      add_newline = lib.mkDefault false;
      aws.disabled = lib.mkDefault true;
      azure.disabled = lib.mkDefault true;
      battery.disabled = lib.mkDefault true;
      buf.disabled = lib.mkDefault true;
      bun.disabled = lib.mkDefault true;
      c.disabled = lib.mkDefault true;
      character = {
        disabled = lib.mkDefault false;
        error_symbol = lib.mkDefault ''

          [➜](bold red)'';
        success_symbol = lib.mkDefault ''

          [➜](bold green)'';
      };
      cmake.disabled = lib.mkDefault true;
      cmd_duration.disabled = lib.mkDefault true;
      cobol.disabled = lib.mkDefault true;
      conda.disabled = lib.mkDefault true;
      container.disabled = lib.mkDefault true;
      crystal.disabled = lib.mkDefault true;
      daml.disabled = lib.mkDefault true;
      dart.disabled = lib.mkDefault true;
      deno.disabled = lib.mkDefault true;
      docker_context.disabled = lib.mkDefault true;
      dotnet.disabled = lib.mkDefault true;
      elixir.disabled = lib.mkDefault true;
      elm.disabled = lib.mkDefault true;
      env_var.disabled = lib.mkDefault true;
      erlang.disabled = lib.mkDefault true;
      fennel.disabled = lib.mkDefault true;
      fill.disabled = lib.mkDefault true;
      fossil_branch.disabled = lib.mkDefault true;
      gcloud.disabled = lib.mkDefault true;
      git_branch = {
        disabled = lib.mkDefault false;
        symbol = lib.mkDefault " ";
      };
      git_commit.disabled = lib.mkDefault false;
      git_state.disabled = lib.mkDefault false;
      git_metrics.disabled = lib.mkDefault false;
      git_status = {
        disabled = lib.mkDefault false;
        ahead = lib.mkDefault "";
        behind = lib.mkDefault "";
        diverged = lib.mkDefault "";
        typechanged = lib.mkDefault "[⇢\($count\)](bold green)";
      };
      golang.disabled = lib.mkDefault true;
      guix_shell.disabled = lib.mkDefault true;
      gradle.disabled = lib.mkDefault false;
      haskell.disabled = lib.mkDefault true;
      haxe.disabled = lib.mkDefault true;
      helm.disabled = lib.mkDefault true;
      hg_branch.disabled = lib.mkDefault true;
      hostname.disabled = lib.mkDefault true;
      java.disabled = lib.mkDefault false;
      jobs.disabled = lib.mkDefault true;
      julia.disabled = lib.mkDefault true;
      kotlin.disabled = lib.mkDefault true;
      kubernetes.disabled = lib.mkDefault true;
      line_break.disabled = lib.mkDefault true;
      localip.disabled = lib.mkDefault true;
      lua.disabled = lib.mkDefault true;
      memory_usage.disabled = lib.mkDefault true;
      meson.disabled = lib.mkDefault true;
      nim.disabled = lib.mkDefault true;
      nix_shell.disabled = lib.mkDefault false;
      nodejs.disabled = lib.mkDefault true;
      ocaml.disabled = lib.mkDefault true;
      opa.disabled = lib.mkDefault true;
      openstack.disabled = lib.mkDefault true;
      os.disabled = lib.mkDefault true;
      package.disabled = lib.mkDefault false;
      perl.disabled = lib.mkDefault true;
      php.disabled = lib.mkDefault true;
      pijul_channel.disabled = lib.mkDefault true;
      pulumi.disabled = lib.mkDefault true;
      purescript.disabled = lib.mkDefault true;
      python.disabled = lib.mkDefault false;
      rlang.disabled = lib.mkDefault true;
      raku.disabled = lib.mkDefault true;
      red.disabled = lib.mkDefault true;
      ruby.disabled = lib.mkDefault true;
      rust.disabled = lib.mkDefault false;
      scala.disabled = lib.mkDefault true;
      shell.disabled = lib.mkDefault true;
      shlvl.disabled = lib.mkDefault true;
      singularity.disabled = lib.mkDefault true;
      solidity.disabled = lib.mkDefault true;
      spack.disabled = lib.mkDefault true;
      status.disabled = lib.mkDefault true;
      sudo.disabled = lib.mkDefault true;
      swift.disabled = lib.mkDefault true;
      terraform.disabled = lib.mkDefault true;
      time.disabled = lib.mkDefault true;
      vagrant.disabled = lib.mkDefault true;
      vlang.disabled = lib.mkDefault true;
      vcsh.disabled = lib.mkDefault true;
      zig.disabled = lib.mkDefault true;
    };
  };

  programs.zoxide = {
    enable = lib.mkDefault true;
    enableBashIntegration = lib.mkDefault true;
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

  home.stateVersion = "21.05";
}
