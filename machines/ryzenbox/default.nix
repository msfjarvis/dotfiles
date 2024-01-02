{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  profiles.tailscale.enable = true;

  # Theming
  stylix = {
    autoEnable = false;
    image = pkgs.fetchurl {
      url = "https://msfjarvis.dev/images/wallpaper.png";
      sha256 = "sha256-GoF4dZTt/+rDrp1Z7+lY/8doSzqiqyXikR1gXDyxkQg=";
    };
    base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
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
        applications = 12;
        terminal = 10;
      };
    };
    opacity = {
      terminal = 0.6;
    };
    polarity = "dark";
    targets = {
      console.enable = true;
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  programs.seahorse.enable = false;
  services.gnome.gnome-keyring.enable = true;

  home-manager.users.msfjarvis = {
    programs.mpv.enable = true;
    dconf.settings = {
      "org/cinnamon/theme" = {
        name = "Dracula";
      };
      "org/cinnamon/desktop/interface" = with config.stylix.fonts; {
        cursor-theme = "Bibata-Modern-Classic";
        font-name = "${sansSerif.name} ${toString sizes.applications}";
        icon-theme = "Dracula";
      };
      "org/cinnamon/desktop/background" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri = "file://${config.stylix.image}";
        picture-uri-dark = "file://${config.stylix.image}";
      };
      "org/gnome/desktop/interface" = with config.stylix.fonts; {
        theme = "Dracula";
        cursor-theme = "Bibata-Modern-Classic";
        icon-theme = "Dracula";
        font-name = "${sansSerif.name} ${toString sizes.applications}";
        document-font-name = "${serif.name} ${toString (sizes.applications - 1)}";
        monospace-font-name = "${monospace.name} ${toString sizes.terminal}";
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
  };

  # Workaround for https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  services.xserver = {
    layout = "us";
    xkbVariant = "";
    enable = true;
    desktopManager = {
      cinnamon.enable = true;
    };
    displayManager = {
      defaultSession = "cinnamon";
      lightdm.enable = true;
    };
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

  users.users.msfjarvis = {
    isNormalUser = true;
    description = "Harsh Shandilya";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      adb-sync
      adx
      age
      diffuse-bin
      dracula-icon-theme
      dracula-theme
      fclones
      ffmpeg
      firefox
      fzf
      gdrive
      git-crypt
      imwheel
      nerdfonts
      katbin
      kondo
      maestro
      megatools
      mullvad
      mullvad-vpn
      patreon-dl
      pidcat
      (python311.withPackages (ps: with ps; [beautifulsoup4 black requests virtualenv]))
      scrcpy
      spotify
      telegram-desktop
      thunderbird
      webcord
      xclip
      xdotool
      yt-dlp

      # Android Development
      androidStudioPackages.stable
      androidStudioPackages.beta
      androidStudioPackages.canary
      (gradle_8.override {
        java = temurin-bin-20;
        javaToolchains = [temurin-bin-17 temurin-bin-20];
      })
      temurin-bin-20

      # Minecraft
      (prismlauncher.override {
        jdks = [temurin-bin-20];
      })
    ];
  };

  services.mullvad-vpn = {
    enable = true;
  };
  # Required for Mullvad
  # https://discourse.nixos.org/t/connected-to-mullvadvpn-but-no-internet-connection/35803/11
  services.resolved.enable = true;

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

  services.rucksack = let
    inherit (config.users.users.msfjarvis) home;
    minecraft = name: "${home}/Games/PrismLauncher/instances/${name}/.minecraft/screenshots/";
  in {
    enable = true;
    sources = [
      (minecraft "1.21")
      (minecraft "Fabulously.Optimized.1.20.2")
      (minecraft "Fabulously.Optimized.MC.1.17.1")
      (minecraft "Fabulously.Optimized.MC.1.20.1")
      (minecraft "Pokemon Elysium")
      "${home}/Games/PrismLauncher/instances/Vault Hunters 3/minecraft/screenshots/"
    ];
    target = "/mediahell/screenshots/";
    file_filter = "*.png";
    user = "msfjarvis";
    group = "users";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
