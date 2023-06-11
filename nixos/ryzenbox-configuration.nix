{
  config,
  pkgs,
  ...
}: {
  home.username = "msfjarvis";
  home.homeDirectory = "/home/msfjarvis";

  fonts.fontconfig.enable = true;

  xdg = {
    enable = true;
    mime.enable = true;
  };

  targets.genericLinux.enable = true;

  home.file.".imwheelrc".text = ''
    ".*"
    None,      Up,   Button4, 3
    None,      Down, Button5, 3
    Control_L, Up,   Control_L|Button4
    Control_L, Down, Control_L|Button5
    Shift_L,   Up,   Shift_L|Button4
    Shift_L,   Down, Shift_L|Button5
  '';

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
    config = {theme = "zenburn";};
  };

  programs.bottom = {enable = true;};

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
      browser = "google-chrome-stable";
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
    ];
    includes = [
      {path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig";}
      {
        path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig-auth";
      }
    ];
  };

  programs.home-manager = {enable = true;};

  programs.jq = {enable = true;};

  programs.micro = {
    enable = true;
    settings = {
      colorscheme = "dracula";
      mkparents = true;
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
      python.disabled = true;
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

  programs.topgrade = {
    enable = true;

    settings = {
      disable = ["gnome_shell_extensions" "home_manager" "nix" "node" "sdkman"];
      display_preamble = false;

      remote_topgrades = ["boatymcboatface"];
      remote_topgrade_path = ".nix-profile/bin/topgrade";

      set_title = false;
      cleanup = true;
    };
  };

  programs.vscode = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 600;
    pinentryFlavor = "gtk2";
    enableBashIntegration = true;
  };

  services.password-store-sync = {
    enable = true;
    frequency = "*-*-* *:00:00";
  };

  systemd.user.services.file-collector = {
    Unit = {
      Description = "systemd service for file-collector";
      After = "local-fs.target";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.custom.file-collector}/bin/file-collector";
      Restart = "on-failure";
      RestartSec = 3;
      Environment = "PATH=${pkgs.watchman}/bin";
    };
    Install = {WantedBy = ["default.target"];};
  };

  systemd.user.services.clipboard-substitutor = {
    Unit = {Description = "systemd service for clipboard-substitutor";};
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.custom.clipboard-substitutor}/bin/clipboard-substitutor";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {WantedBy = ["default.target"];};
  };

  systemd.user.services.imwheel = {
    Unit = {
      Description = "systemd service for imwheel";
      Wants = "display-manager.service";
      After = "display-manager.service";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.imwheel}/bin/imwheel -d";
      ExecStop = "/usr/bin/pkill imwheel";
      RemainAfterExit = "yes";
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {WantedBy = ["default.target"];};
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
    Timer = {OnCalendar = "daily";};
    Install = {WantedBy = ["timers.target"];};
  };

  home.packages = with pkgs; [
    custom.adb-sync
    custom.adbtuifm
    custom.adx
    age
    alejandra
    custom.bundletool-bin
    cachix
    comma
    curl
    delta
    custom.diffuse-bin
    diskus
    dos2unix
    fclones
    fd
    ferium
    (ffmpeg.override {
      buildFfplay = false;
      buildFfprobe = true;
      buildQtFaststart = false;
      withDav1d = true;
      withMp3lame = true;
      withAss = true;
      withDrm = true;
      withVaapi = true;
      withVdpau = true;
      withVorbis = true;
      withVpx = true;
      withWebp = true;
      withNvdec = true;
      withNvenc = true;
      withX264 = true;
      withX265 = true;
    })
    fzf
    custom.gdrive
    git-absorb
    git-crypt
    git-quickfix
    custom.hcctl
    hub
    imwheel
    (nerdfonts.override {
      fonts = ["CascadiaCode" "FiraCode" "Inconsolata" "JetBrainsMono"];
    })
    custom.katbin
    (maestro.overrideAttrs (self: super: {
      postFixup = "";
    }))
    mcfly
    megatools
    mmv-go
    mosh
    ncdu_2
    neofetch
    nil
    nix-init
    nix-update
    nixpkgs-review
    nvd
    openssl
    custom.patreon-dl
    custom.pidcat
    (python39.withPackages (ps: with ps; [virtualenv]))
    ripgrep
    scrcpy
    sd
    shellcheck
    shfmt
    custom.twt
    unzip
    vivid
    custom.when
    xclip
    yt-dlp
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
