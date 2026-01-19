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
    # last checked with https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-main/os/x86_64/steamos-customizations-jupiter-20250117.1-1-any.pkg.tar.zst
    boot.kernel.sysctl = {
      # 20-shed.conf
      "kernel.sched_cfs_bandwidth_slice_us" = 3000;
      # 20-net-timeout.conf
      # This is required due to some games being unable to reuse their TCP ports
      # if they're killed and restarted quickly - the default timeout is too large.
      "net.ipv4.tcp_fin_timeout" = 5;
      # 30-splitlock.conf
      # Prevents intentional slowdowns in case games experience split locks
      # This is valid for kernels v6.0+
      "kernel.split_lock_mitigate" = 0;
      # 30-vm.conf
      # USE MAX_INT - MAPCOUNT_ELF_CORE_MARGIN.
      # see comment in include/linux/mm.h in the kernel tree.
      "vm.max_map_count" = 2147483642;
    };

    environment.systemPackages = with pkgs; [
      cartridges
      mangohud
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
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
        extraPkgs = p: with p; [ gamemode ];
      };
    };

    programs.gamemode = {
      enable = true;
      enableRenice = true;
    };

    # Pipewire LowLatency configuration from nix-gaming
    # ref: https://github.com/fufexan/nix-gaming/blob/6caa391790442baea22260296041429fb365e0ce/modules/pipewireLowLatency.nix
    services.pipewire = {
      enable = true;
      # write extra config
      extraConfig = {
        pipewire."99-lowlatency" = {
          "context.properties"."default.clock.min-quantum" = quantum;

          "context.modules" = [
            {
              name = "libpipewire-module-rt";
              flags = [
                "ifexists"
                "nofail"
              ];
              args = {
                "nice.level" = -15;
                "rt.prio" = 88;
                "rt.time.soft" = 200000;
                "rt.time.hard" = 200000;
              };
            }
          ];
        };

        pipewire-pulse."99-lowlatency"."pulse.properties" = {
          "server.address" = [ "unix:native" ];
          "pulse.min.req" = qr;
          "pulse.min.quantum" = qr;
          "pulse.min.frag" = qr;
        };

        client."99-lowlatency"."stream.properties" = {
          "node.latency" = qr;
          "resample.quality" = 1;
        };
      };

      # ensure WirePlumber is enabled explicitly
      wireplumber = {
        enable = true;
      };
    };

    users.users.msfjarvis.packages = with pkgs; [
      # Supplied by Cartridges, restore when removing it.
      # (pkgs.${namespace}.game-shortcuts.override {
      #   games = [
      #     {
      #       name = "Hades";
      #       id = 1145360;
      #     }
      #     {
      #       name = "HoloCure";
      #       id = 2420510;
      #     }
      #     {
      #       name = "Marvel Snap";
      #       id = 1997040;
      #     }
      #     {
      #       name = "Satisfactory";
      #       id = 526870;
      #     }
      #   ];
      # })
      (heroic.override {
        extraPkgs = p: with p; [ gamemode ];
      })
      ficsit-cli
    ];

    # Required to avoid some logspew
    environment.sessionVariables.VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    environment.variables = {
      # better fonts:
      # https://web.archive.org/web/20230921201835/https://old.reddit.com/r/linux_gaming/comments/16lwgnj/is_it_possible_to_improve_font_rendering_on_linux/
      FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
    };
  };
}
