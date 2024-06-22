{
  pkgs,
  config,
  inputs,
  namespace,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  topology.self.name = "Desktop";

  profiles.tailscale.enable = true;
  profiles.desktop.enable = true;
  profiles.desktop.android-dev.enable = true;
  profiles.desktop.gnome3.enable = true;
  profiles.desktop.noise-cancelation.enable = true;

  # Only enable for first installation
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

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
    ];
    packages = with pkgs; [
      age
      attic
      pkgs.${namespace}.boop-gtk
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
      fzf
      gallery-dl
      pkgs.${namespace}.gdrive
      git-crypt
      forge-sparks
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
      pipeline
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
      scrcpy
      smile
      sshfs
      telegram-desktop
      thunderbird
      tuba
      uv
      vesktop
      xdotool
      yt-dlp

      # Minecraft
      mcaselector
      (prismlauncher.override {
        jdks = [ openjdk22 ];
        withWaylandGLFW = config.profiles.desktop.gnome3.enable;
      })
    ];
  };

  services.mullvad-vpn = {
    enable = true;
  };
  # Required for Mullvad
  # https://discourse.nixos.org/t/connected-to-mullvadvpn-but-no-internet-connection/35803/11
  services.resolved.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    icu
    openssl
    stdenv.cc.cc
    zlib
  ];

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraLibraries =
        p: with p; [
          cairo
          gccForLibs.lib
          gdk-pixbuf
          gtk3
          pango
        ];
    };
  };
  # Required to avoid some logspew
  environment.sessionVariables.VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";

  services.glance = {
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
                      url = "https://cache.msfjarvis.dev";
                    }
                    {
                      title = "Git mirror";
                      url = "https://git.msfjarvis.dev";
                    }
                    {
                      title = "Grafana";
                      url = "https://grafana.msfjarvis.dev";
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
                      title = "QBittorrent";
                      url = "https://crusty.tiger-shark.ts.net";
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
                    "camila"
                    "couriway"
                    "geminitay"
                    "laynalazar"
                    "matarakan"
                    "michimochievee"
                    "mush"
                    "pearlescentmoon"
                    "piratesoftware"
                    "squchan"
                    "thinkingmansvalo"
                    "trickywi"
                    "zentreya"
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

  services.gphotos-cdp = {
    enable = true;
    session-dir = "/home/msfjarvis/harsh-sess";
    dldir = "/home/msfjarvis/harsh-photos";
    user = "msfjarvis";
    group = "users";
  };

  services.rucksack =
    let
      inherit (config.users.users.msfjarvis) home;
      minecraft = name: "${home}/Games/PrismLauncher/instances/${name}/.minecraft/screenshots/";
    in
    {
      enable = true;
      sources = [
        (minecraft "1.21")
        (minecraft "ACLU SMP Modpack")
        (minecraft "Fabulously.Optimized.1.20.2")
        (minecraft "Fabulously.Optimized.1.20.6")
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
