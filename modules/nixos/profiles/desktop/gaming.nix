{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  quantum = 64;
  rate = 48000;
  qr = "${toString quantum}/${toString rate}";
  cfg = config.profiles.${namespace}.desktop;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.desktop.gaming = {
    enable = mkEnableOption "set up epic gamer stuff";
  };
  config = mkIf cfg.gaming.enable {
    # last checked with https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/steamos-customizations-jupiter-20240219.1-2-any.pkg.tar.zst
    boot.kernel.sysctl = {
      # 20-shed.conf
      "kernel.sched_cfs_bandwidth_slice_us" = 3000;
      # 20-net-timeout.conf
      # This is required due to some games being unable to reuse their TCP ports
      # if they are killed and restarted quickly - the default timeout is too large.
      "net.ipv4.tcp_fin_timeout" = 5;
      # 30-vm.conf
      # USE MAX_INT - MAPCOUNT_ELF_CORE_MARGIN.
      # see comment in include/linux/mm.h in the kernel tree.
      "vm.max_map_count" = 2147483642;
    };
    environment.systemPackages = with pkgs; [
      mangohud
      gpu-screen-recorder-gtk
    ];
    programs.gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--steam"
        "--expose-wayland"
        "--rt"
        "-W 2560"
        "-H 1440"
        "--force-grab-cursor"
        "--grab"
        "--fullscreen"
      ];
    };
    programs.gpu-screen-recorder = {
      enable = true;
    };
    programs.steam = {
      enable = true;
      # Graphical glitches and broken rendering
      gamescopeSession.enable = false;
      package = pkgs.steam.override {
        extraLibraries =
          p: with p; [
            # Tiny Glade
            cairo
            gccForLibs.lib
            gdk-pixbuf
            gtk3
            pango
          ];
      };
    };
    programs.nix-ld = {
      enable = true;
      libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs;
    };

    snowfallorg.users.msfjarvis.home.config = {
      systemd.user.services.steam = {
        Unit.Description = "Open Steam in the background at boot";
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          ExecStart = "${lib.getExe pkgs.steam} -nochatui -nofriendsui -silent %U";
          Restart = "always";
          RestartSec = "5s";
        };
      };
    };
    # Pipewire LowLatency configuration from nix-gaming
    # ref: https://github.com/fufexan/nix-gaming/blob/6caa391790442baea22260296041429fb365e0ce/modules/pipewireLowLatency.nix
    services.pipewire = {
      extraConfig.pipewire = {
        "99-lowlatency" = {
          context = {
            properties.default.clock.min-quantum = quantum;
            modules = [
              {
                name = "libpipewire-module-rtkit";
                flags = [
                  "ifexists"
                  "nofail"
                ];
                args = {
                  nice.level = -15;
                  rt = {
                    prio = 88;
                    time.soft = 200000;
                    time.hard = 200000;
                  };
                };
              }
              {
                name = "libpipewire-module-protocol-pulse";
                args = {
                  server.address = [ "unix:native" ];
                  pulse.min = {
                    req = qr;
                    quantum = qr;
                    frag = qr;
                  };
                };
              }
            ];

            stream.properties = {
              node.latency = qr;
              resample.quality = 1;
            };
          };
        };
      };
    };

    users.users.msfjarvis.packages = with pkgs; [
      # Minecraft
      mcaselector
      (prismlauncher.override {
        jdks = [ openjdk22 ];
      })
      (pkgs.${namespace}.game-shortcuts.override {
        games = [
          {
            name = "Hades";
            id = 1145360;
          }
          {
            name = "Helldivers 2";
            id = 553850;
          }
          {
            name = "Hollow Knight";
            id = 367520;
          }
          {
            name = "Marvel Snap";
            id = 1997040;
          }
        ];
      })
    ];
    # Required to avoid some logspew
    environment.sessionVariables.VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
  };
}
