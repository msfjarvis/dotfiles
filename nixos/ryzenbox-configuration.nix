{
  config,
  pkgs,
  ...
}: {
  imports = [./modules/vscode/home-manager.nix];
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

  programs.gh = {
    settings = {
      browser = "google-chrome-stable";
    };
  };

  programs.git = {
    includes = [
      {path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig";}
      {
        path = "${config.home.homeDirectory}/git-repos/dotfiles/.gitconfig-auth";
      }
    ];
  };

  programs.micro = {
    enable = true;
    settings = {
      colorscheme = "dracula";
      mkparents = true;
      softwrap = true;
      wordwrap = true;
    };
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [exts.pass-audit exts.pass-genphrase exts.pass-otp exts.pass-update]);
  };

  programs.topgrade = {
    enable = true;

    settings = {
      misc = {
        assume_yes = true;
        pre_sudo = true;
        remote_topgrades = ["boatymcboatface"];
        remote_topgrade_path = ".nix-profile/bin/topgrade";
        set_title = true;
        skip_notify = true;
        disable = ["gnome_shell_extensions" "home_manager" "nix" "node" "sdkman"];
      };
    };
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
      ExecStart = "${pkgs.file-collector}/bin/file-collector";
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
    adbtuifm
    adx
    age
    alejandra
    aria2gtls
    bundletool-bin
    cachix
    curl
    delta
    diffuse-bin
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
    gdrive
    git-absorb
    git-crypt
    git-quickfix
    hcctl
    hub
    imwheel
    (nerdfonts.override {
      fonts = ["CascadiaCode" "FiraCode" "Inconsolata" "JetBrainsMono"];
    })
    katbin
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
    patreon-dl
    pidcat
    (python311.withPackages (ps: with ps; [beautifulsoup4 requests virtualenv]))
    ripgrep
    scrcpy
    sd
    shellcheck
    shfmt
    spicetify-cli
    taplo
    twt
    unzip
    vivid
    when
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
