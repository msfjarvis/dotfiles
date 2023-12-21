{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Theming
  stylix = {
    autoEnable = false;
    image = pkgs.fetchurl {
      url = "https://msfjarvis.dev/images/wallpaper.png";
      sha256 = "sha256-S3GbyhdySaiPOHQyYxANC3jM19rD+6OKh7Q+DojqdOk=";
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";

    cursor = {
      package = pkgs.dracula-gtk-theme-unstable;
      name = "Dracula-cursors";
    };
    fonts = {
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-color-emoji;
      };
      monospace = {
        name = "JetBrainsMonoNL Nerd Font Mono Regular";
        package = pkgs.nerdfonts;
      };
      sansSerif = {
        name = "Roboto Regular";
        package = pkgs.roboto;
      };
      serif = {
        name = "Roboto Serif 20pt Regular";
        package = pkgs.roboto-serif;
      };
      sizes = {
        applications = 10.0;
        terminal = 10.0;
      };
    };
    opacity = {
      terminal = 0.6;
    };
    polarity = "dark";
    targets = {
      console.enable = true;
      gnome.enable = true;
      gtk.enable = true;
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  home-manager.users.msfjarvis = {
    programs.mpv.enable = true;
    gtk = {
      enable = true;
      theme = {
        name = "Dracula";
        package = pkgs.dracula-gtk-theme-unstable;
      };
      cursorTheme = {
        name = "Dracula-cursors";
        package = pkgs.dracula-gtk-theme-unstable;
      };
      gtk3.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };

      gtk4.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };
    };
    dconf.settings = {
      "org/gnome/shell/extensions/user-theme" = {
        name = "Dracula";
      };
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          "arcmenu@arcmenu.com"
          "pop-shell@system76.com"
          "sound-output-device-chooser@kgshank.net"
          "System_Monitor@bghome.gmail.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
        ];
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        cursor-theme = "Dracula-cursors";
        gtk-theme = "Dracula";
      };
    };
    home.sessionVariables.GTK_THEME = "Dracula";
    stylix = {
      targets = {
        bat.enable = true;
        firefox = {
          enable = true;
          profileNames = [
            "Primary"
            "Secondary"
          ];
        };
        fzf.enable = true;
      };
    };
  };

  # Enable networking
  networking = {
    hostName = "ryzenbox";
    networkmanager.enable = true;
    nameservers = ["100.100.100.100" "8.8.8.8" "1.1.1.1"];
    search = ["tiger-shark.ts.net"];
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.msfjarvis = {
    isNormalUser = true;
    description = "Harsh Shandilya";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      adb-sync
      adx
      age
      diffuse-bin
      fclones
      ferium
      ffmpeg
      firefox-wayland
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
      scrcpy
      spotify
      spicetify-cli
      sshfs
      telegram-desktop
      thunderbird
      wl-clipboard
      xdotool
      yt-dlp

      # Android Development
      android-studio
      androidStudioPackages.canary
      (gradle_8.override {
        java = temurin-bin-20;
        javaToolchains = [temurin-bin-17 temurin-bin-20];
      })
      temurin-bin-20

      # Minecraft
      (prismlauncher.override {
        glfw = glfw-wayland-minecraft;
        jdks = [temurin-bin-20];
      })

      # GNOME
      gnome3.gnome-tweaks
      # a nicer application menu for gnome
      gnomeExtensions.arcmenu
      # POP!_OS shell tiling extensions for Gnome 3
      gnomeExtensions.pop-shell
      # allows selecting the sound output device in the sound menu
      gnomeExtensions.sound-output-device-chooser
      # displays system status in the gnome-shell status bar
      gnomeExtensions.system-monitor
      gnomeExtensions.user-themes
    ];
  };

  services.tailscale = {
    enable = true;
  };

  services.tailscale-autoconnect = {
    enable = true;
    authkeyFile = "/run/secrets/tsauthkey";
  };

  systemd.user.services.clipboard-substitutor = {
    unitConfig = {Description = "systemd service for clipboard-substitutor";};
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.clipboard-substitutor}/bin/clipboard-substitutor";
      Restart = "on-failure";
      RestartSec = 3;
    };
    wantedBy = ["default.target"];
  };

  systemd.user.services.imwheel = {
    unitConfig = {
      Description = "systemd service for imwheel";
      Wants = "display-manager.service";
      After = "display-manager.service";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.imwheel}/bin/imwheel -d";
      ExecStop = "/usr/bin/pkill imwheel";
      RemainAfterExit = "yes";
      Restart = "on-failure";
      RestartSec = 3;
    };
    wantedBy = ["default.target"];
  };

  programs.adb.enable = true;
  services.udev.packages = [
    pkgs.android-udev-rules
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
