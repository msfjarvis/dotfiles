{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.mpv;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.mpv = {
    enable = mkEnableOption "Enable MPV player";
  };
  config = mkIf cfg.enable {
    catppuccin.mpv.enable = true;
    programs.mpv = {
      enable = true;
      package = pkgs.mpv-unwrapped.wrapper {
        mpv = pkgs.mpv-unwrapped.override {
          waylandSupport = false;
          x11Support = true;
          cddaSupport = false;
          vulkanSupport = false;
          drmSupport = false;
          archiveSupport = false;
          bluraySupport = false;
          bs2bSupport = false;
          cacaSupport = false;
          cmsSupport = false;
          dvdnavSupport = false;
          dvbinSupport = false;
          jackaudioSupport = false;
          javascriptSupport = false;
          openalSupport = false;
          pulseSupport = false;
          pipewireSupport = true;
          rubberbandSupport = false;
          sdl2Support = true;
          sixelSupport = false;
          vaapiSupport = true;
          vapoursynthSupport = false;
          vdpauSupport = true;
          zimgSupport = false;
        };
        scripts = with pkgs.mpvScripts; [
          uosc
          thumbfast
          inhibit-gnome
        ];

      };
      config = {
        autofit = "100%";
        window-maximized = "yes";
        hwdec = "nvdec";
      };
    };
  };
}
