{
  config,
  lib,
  pkgs,
  nixGLWrap,
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

  programs.bash = {
    historyFile = "${config.home.homeDirectory}/.bash_history";
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
  };

  programs.browserpass = {
    enable = true;
    browsers = ["firefox"];
  };

  programs.git = {
    includes = [
      {path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig";}
      {
        path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig-auth";
      }
    ];
  };

  programs.topgrade = {
    enable = true;

    settings = {
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
    enable = true;
    defaultCacheTtl = 3600;
    pinentryFlavor = "gnome3";
    enableBashIntegration = true;
  };

  services.git-sync = {
    enable = true;
    repositories.password-store = {
      path = config.programs.password-store.settings.PASSWORD_STORE_DIR;
      uri = "git+ssh://msfjarvis@github.com:msfjarvis/pass-store.git";
      interval = 600;
    };
  };

  systemd.user.systemctlPath = "/usr/bin/systemctl";

  systemd.user.services.rucksack = {
    Unit = {
      Description = "systemd service for rucksack";
      After = "local-fs.target";
    };
    Service = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.rucksack}";
      Restart = "on-failure";
      RestartSec = 3;
      Environment = "PATH=${pkgs.watchman}/bin";
    };
    Install = {WantedBy = ["default.target"];};
  };

  systemd.user.services.rucksack-restart = {
    Service = {
      Type = "oneshot";
      ExecStart = "${config.systemd.user.systemctlPath} --user restart rucksack.service";
    };
    Install = {WantedBy = ["multi-user.target"];};
  };

  systemd.user.paths.rucksack-restart = {
    Path = {
      PathChanged = "${config.home.homeDirectory}/.config/rucksack.toml";
    };
    Install = {WantedBy = ["multi-user.target"];};
  };

  systemd.user.services.clipboard-substitutor = {
    Unit = {Description = "systemd service for clipboard-substitutor";};
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.clipboard-substitutor}/bin/clipboard-substitutor";
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

  home.packages = with pkgs; [
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
    (nixGLWrap "scrcpy" scrcpy)
    spicetify-cli
    transmission
    when
    xclip
    xdotool
    yt-dlp
  ];
}
