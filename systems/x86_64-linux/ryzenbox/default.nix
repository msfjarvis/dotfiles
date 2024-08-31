{
  lib,
  pkgs,
  config,
  inputs,
  namespace,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  topology.self.name = "Desktop";

  profiles.${namespace} = {
    tailscale.enable = true;
    desktop.enable = true;
    desktop.android-dev.enable = true;
    desktop.gaming.enable = true;
    desktop.gnome3.enable = true;
    desktop.noise-cancelation.enable = true;
  };

  # Only enable for first installation
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # Enable SOPS, force it to be age-only
  sops.age.sshKeyPaths = lib.mkForce [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.gnupg.sshKeyPaths = lib.mkForce [ ];

  snowfallorg.users.msfjarvis.home.config = {
    stylix = {
      targets = {
        firefox = {
          enable = true;
          profileNames = [
            "Primary"
            "Secondary"
          ];
        };
      };
    };
  };

  # Enable networking
  networking = {
    hostName = "ryzenbox";
    nftables.enable = true;
    # KDEConnect needs these ports
    firewall = {
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  services.libinput = {
    enable = true;
    mouse.accelProfile = "flat";
  };

  users.users.msfjarvis = {
    isNormalUser = true;
    description = "Harsh Shandilya";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
    packages = with pkgs; [
      age
      attic
      pkgs.${namespace}.boop-gtk
      pkgs.${namespace}.cyberdrop-dl
      fclones
      (ffmpeg.override {
        buildFfplay = false;
        buildFfprobe = true;
        buildQtFaststart = false;
        withAom = true;
        withAss = true;
        withDav1d = true;
        withDrm = true;
        withMp3lame = true;
        withNvdec = true;
        withNvenc = true;
        withRav1e = true;
        withVaapi = true;
        withVdpau = true;
        withVorbis = true;
        withVpx = true;
        withWebp = true;
        withX264 = true;
        withX265 = true;
      })
      (inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin.override {
        cfg = {
          smartcardSupport = true;
          pipewireSupport = true;
        };
      })
      forge-sparks
      fzf
      gallery-dl
      pkgs.${namespace}.gdrive
      git-crypt
      git-lfs
      # handbrake
      nerdfonts
      pkgs.${namespace}.katbin
      kondo
      maestro
      megatools
      mullvad
      mullvad-vpn
      newsflash
      nix-init
      nix-update
      nurl
      pkgs.${namespace}.patreon-dl
      pkgs.${namespace}.pidcat
      (python312.withPackages (
        ps: with ps; [
          beautifulsoup4
          black
          requests
          virtualenv
        ]
      ))
      restic
      scrcpy
      smile
      sshfs
      telegram-desktop
      thunderbird
      tuba
      uv
      vesktop
      yt-dlp
    ];
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.mullvad-vpn = {
    enable = true;
  };
  # Required for Mullvad
  # https://discourse.nixos.org/t/connected-to-mullvadvpn-but-no-internet-connection/35803/11
  services.resolved.enable = true;

  sops.secrets.restic_minecraft_repo_url = {
    sopsFile = lib.snowfall.fs.get-file "secrets/restic/repo.yaml";
    owner = config.services.restic.backups.minecraft.user;
  };
  sops.secrets.restic_screenshots_repo_url = {
    sopsFile = lib.snowfall.fs.get-file "secrets/restic/repo.yaml";
    owner = config.services.restic.backups.minecraft.user;
  };
  sops.secrets.restic_repo_password = {
    sopsFile = lib.snowfall.fs.get-file "secrets/restic/password.yaml";
    owner = config.services.restic.backups.minecraft.user;
  };
  services.restic.backups = {
    minecraft = {
      initialize = true;
      repositoryFile = config.sops.secrets.restic_minecraft_repo_url.path;
      passwordFile = config.sops.secrets.restic_repo_password.path;

      paths = [ "${config.users.users.msfjarvis.home}/Games/PrismLauncher/instances" ];

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 2"
        "--keep-monthly 10"
      ];
    };
    screenshots = {
      initialize = true;
      repositoryFile = config.sops.secrets.restic_screenshots_repo_url.path;
      passwordFile = config.sops.secrets.restic_repo_password.path;

      paths = [ "/mediahell/screenshots" ];

      pruneOpts = [
        "--keep-daily 5"
        "--keep-weekly 1"
        "--keep-monthly 1"
      ];
    };
  };

  services.${namespace} = {
    # Duplicated in Matara, keep both in sync until Matara is deployed then delete this.
    glance = {
      enable = true;
      user = "msfjarvis";
      group = "users";
      settings = {
        server.port = 8080;
        theme = {
          background-color = "240 21 15";
          contrast-multiplier = 1.2;
          primary-color = "217 92 83";
          positive-color = "115 54 76";
          negative-color = "347 70 65";
        };
        pages = [
          {
            name = "Home";
            columns = [
              {
                size = "full";
                widgets = [
                  { type = "calendar"; }
                  {
                    type = "videos";
                    cache = "15m";
                    channels = [
                      "UClu2e7S8atp6tG2galK9hgg"
                      "UC9lJXqw4QZw-HWaZH6sN-xw"
                      "UC4O9HKe9Jt5yAhKuNv3LXpQ"
                      "UCFKDEp9si4RmHFWJW1vYsMA"
                      "UCuQYHhF6on6EXXO-_i_ClHQ"
                      "UCUBsjvdHcwZd3ztdY1Zadcw"
                      "UCR9Gcq0CMm6YgTzsDxAxjOQ"
                      "UCuMJPFqazQI4SofSFEd-5zA"
                      "UCZ9x-z3iOnIbJxVpm1rsu2A"
                      "UCrEtZMErQXaSYy_JDGoU5Qw"
                      "UCcJgOennb0II4a_qi9OMkRA"
                      "UChFur_NwVSbUozOcF_F2kMg"
                      "UC1GJ5aeqpEWklMBQ3oXrPQQ"
                      "UCDpdtiUfcdUCzokpRWORRqA"
                      "UCodkNmk9oWRTIYZdr_HuSlg"
                      "UCYdXHOv7srjm-ZsNsTcwbBw"
                      "UC4qdHN4zHhd4VvNy3zNgXPA"
                      "UC24lkOxZYna9nlXYBcJ9B8Q"
                      "UC4YUKOBld2PoOLzk0YZ80lw"
                      "UCU9pX8hKcrx06XfOB-VQLdw"
                      "UCPK5G4jeoVEbUp5crKJl6CQ"
                      "UCjI5qxhtyv3srhWr60HemRw"
                    ];
                  }
                  {
                    type = "reddit";
                    subreddit = "hermitcraft";
                    style = "horizontal-cards";
                    sort-by = "top";
                    top-period = "day";
                  }
                  {
                    type = "reddit";
                    subreddit = "hermitcraftmemes";
                    style = "horizontal-cards";
                    sort-by = "top";
                    top-period = "day";
                  }
                ];
              }
              {
                size = "small";
                widgets = [
                  {
                    type = "releases";
                    cache = "15m";
                    repositories = [
                      "thunderbird/thunderbird-android"
                      "UweTrottmann/SeriesGuide"
                      "JetBrains/Kotlin"
                      "Kotlin/kotlinx.serialization"
                      "Kotlin/kotlinx.coroutines"
                      "square/anvil"
                      "tailscale/tailscale"
                    ];
                  }
                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Services";
                    sites = [
                      {
                        title = "Attic cache";
                        url = "https://nix-cache.tiger-shark.ts.net";
                      }
                      {
                        title = "Git mirror";
                        url = "https://git.msfjarvis.dev";
                      }
                      {
                        title = "Grafana";
                        url = "https://grafana.tiger-shark.ts.net";
                      }
                      {
                        title = "Private file share";
                        url = "https://wailord.tiger-shark.ts.net";
                      }
                      {
                        title = "Public file share";
                        url = "https://til.msfjarvis.dev";
                      }
                      {
                        title = "RSS reader";
                        url = "https://read.msfjarvis.dev";
                      }
                    ];
                  }
                ];
              }
              {
                size = "small";
                widgets = [
                  {
                    type = "weather";
                    location = "New Delhi, India";
                  }
                  {
                    type = "twitch-channels";
                    cache = "1m";
                    channels = [
                      "couriway"
                      "geminitay"
                      "laynalazar"
                      "matarakan"
                      "michimochievee"
                      "mush"
                      "pearlescentmoon"
                      "sliggytv"
                    ];
                  }
                ];
              }
            ];
          }
          {
            name = "Internet";
            columns = [
              {
                size = "full";
                widgets = [
                  {
                    type = "search";
                    search-engine = "https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={QUERY}";
                  }
                  {
                    type = "lobsters";
                    sort-by = "hot";
                  }
                ];
              }
            ];
          }
        ];
      };
    };

    gphotos-cdp = {
      enable = false;
      session-dir = "/home/msfjarvis/harsh-sess";
      dldir = "/home/msfjarvis/harsh-photos";
      user = "msfjarvis";
      group = "users";
    };
    rucksack =
      let
        inherit (config.users.users.msfjarvis) home;
        minecraft = name: "${home}/Games/PrismLauncher/instances/${name}/.minecraft/screenshots/";
      in
      {
        enable = true;
        sources = [
          (minecraft "Fabulously.Optimized.1.20.6")
          (minecraft "Fabulously.Optimized.1.21")
          "${home}/Pictures/Screenshots"
        ];
        target = "/mediahell/screenshots/";
        file_filter = "*.png";
        user = "msfjarvis";
        group = "users";
      };
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
