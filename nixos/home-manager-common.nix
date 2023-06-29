{pkgs, ...}: {
  programs.bat = {
    enable = true;
    config = {theme = "zenburn";};
  };

  programs.bash = {
    enable = true;
    historySize = 1000;
    historyFileSize = 10000;
    historyControl = ["ignorespace" "erasedups"];
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

  programs.bottom = {enable = true;};

  programs.browserpass = {
    enable = true;
    browsers = ["chrome"];
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
  };

  programs.gpg = {enable = true;};

  programs.home-manager = {enable = true;};

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
        typechanged = "[⇢\($count\)](bold green)";
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
      solidity.disabled = true;
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
}
