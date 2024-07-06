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
