{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.desktop;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.desktop.gaming = {
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
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };
    programs.steam = {
      enable = true;
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
      };
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };

    users.users.msfjarvis.packages = with pkgs; [
      # Minecraft
      mcaselector
      (prismlauncher.override {
        jdks = [ openjdk22 ];
        withWaylandGLFW = config.profiles.desktop.gnome3.enable;
      })
    ];
    # Required to avoid some logspew
    environment.sessionVariables.VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
  };
}
