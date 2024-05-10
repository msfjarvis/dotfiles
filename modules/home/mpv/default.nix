{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.profiles.mpv;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.mpv = {
    enable = mkEnableOption "Enable MPV player";
  };
  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;
      package =
        pkgs.wrapMpv
          (pkgs.mpv-unwrapped.override {
            waylandSupport = true;
            x11Support = false;
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
            libpngSupport = false;
            openalSupport = false;
            pulseSupport = false;
            pipewireSupport = true;
            rubberbandSupport = false;
            screenSaverSupport = false;
            sdl2Support = true;
            sixelSupport = false;
            speexSupport = false;
            swiftSupport = false;
            theoraSupport = false;
            vaapiSupport = true;
            vapoursynthSupport = false;
            vdpauSupport = true;
            xineramaSupport = false;
            xvSupport = false;
            zimgSupport = false;
          })
          {
            scripts = with pkgs.mpvScripts; [
              uosc
              thumbfast
              inhibit-gnome
            ];
          };
      config = {
        autofit = "100%";
        window-maximized = "yes";
      };
    };
  };
}
