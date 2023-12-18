{
  config,
  pkgs,
  lib,
  ...
}: {
  home.username = lib.mkDefault "msfjarvis";
  home.homeDirectory = lib.mkDefault "/home/msfjarvis";

  fonts.fontconfig.enable = lib.mkDefault true;

  targets.genericLinux.enable = lib.mkDefault true;

  xdg = {
    enable = lib.mkDefault true;
    mime.enable = lib.mkDefault true;
  };

  home.file.".imwheelrc".text = ''
    ".*"
    None,      Up,   Button4, 3
    None,      Down, Button5, 3
    Control_L, Up,   Control_L|Button4
    Control_L, Down, Control_L|Button5
    Shift_L,   Up,   Shift_L|Button4
    Shift_L,   Down, Shift_L|Button5
  '';

  home.packages = with pkgs;
    [
      adb-sync
      adx
      age
      diffuse-bin
      fclones
      ferium
      ffmpeg
      fzf
      gdrive
      git-crypt
      gitui
      hcctl
      imwheel
      nerdfonts
      katbin
      kondo
      maestro
      megatools
      patreon-dl
      pidcat
      (python311.withPackages (ps: with ps; [beautifulsoup4 black requests virtualenv]))
      #    (nixGLWrap "scrcpy" scrcpy)
      spicetify-cli
      xclip
      xdotool
      yt-dlp
    ]
    ++ (import ./packages.nix) pkgs;

  programs.atuin = {
    enable = lib.mkDefault true;
    enableBashIntegration = lib.mkDefault true;
    flags = lib.mkDefault ["--disable-up-arrow"];
    settings = lib.mkDefault {
      auto_sync = true;
      max_preview_height = 2;
      search_mode = "skim";
      show_preview = true;
      style = "compact";
      sync_frequency = "5m";
      sync_address = "http://crusty:8888";
    };
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
    bashrcExtra = lib.mkDefault ''
      # Load completions from system
      if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
      elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
      fi
      # Source shell-init from my dotfiles
      source ${config.home.homeDirectory}/git-repos/dotfiles/shell-init
    '';
  };

  programs.bat = {
    enable = lib.mkDefault true;
    config = lib.mkDefault {theme = "zenburn";};
  };

  programs.bottom = {enable = lib.mkDefault true;};

  programs.browserpass = {
    enable = lib.mkDefault true;
    browsers = lib.mkDefault ["firefox"];
  };

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
    includes = lib.mkDefault [
      {path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig";}
    ];
  };

  programs.gpg = {enable = lib.mkDefault true;};

  programs.home-manager = {enable = lib.mkDefault true;};

  programs.jq = {enable = lib.mkDefault true;};

  programs.topgrade = {
    enable = lib.mkDefault true;

    settings = lib.mkDefault {
      misc = {
        assume_yes = true;
        pre_sudo = true;
        remote_topgrades = ["backup"];
        remote_topgrade_path = "bin/topgrade";
        set_title = true;
        skip_notify = true;
        only = [
          "firmware"
          "github_cli_extensions"
          "micro"
          "remotes"
          "spicetify"
          "system"
        ];
      };
    };
  };

  services.gpg-agent = {
    enable = lib.mkDefault true;
    defaultCacheTtl = lib.mkDefault 3600;
    pinentryFlavor = lib.mkDefault "gnome3";
    enableBashIntegration = lib.mkDefault true;
  };

  services.git-sync = {
    enable = lib.mkDefault true;
    repositories = lib.mkDefault {
      password-store = {
        path = config.programs.password-store.settings.PASSWORD_STORE_DIR;
        uri = "git+ssh://msfjarvis@github.com:msfjarvis/pass-store.git";
        interval = 600;
      };
    };
  };

  programs.lsd = {
    enable = lib.mkDefault true;
    enableAliases = lib.mkDefault true;
  };

  programs.nix-index = {
    enable = lib.mkDefault true;
    enableBashIntegration = lib.mkDefault true;
  };

  programs.nix-index-database.comma.enable = true;

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

  home.stateVersion = "21.05";
}
