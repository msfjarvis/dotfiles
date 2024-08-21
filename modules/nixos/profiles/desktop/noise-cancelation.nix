{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.desktop;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.desktop.noise-cancelation = {
    enable = mkEnableOption "Enable noise cancelation in PipeWire";
  };
  config = mkIf cfg.noise-cancelation.enable {
    services.pipewire.configPackages = [
      (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/49-noise-cancellation.conf" ''
        context.modules = [
          {
            name = libpipewire-module-filter-chain
            args = {
              node.description = "DeepFilter Noise Canceling Source"
              media.name       = "DeepFilter Noise Canceling Source"
              filter.graph = {
                nodes = [
                  {
                    type   = ladspa
                    name   = "DeepFilter Mono"
                    plugin = "${pkgs.deepfilternet}/lib/ladspa/libdeep_filter_ladspa.so"
                    label  = deep_filter_mono
                    control = {
                      "Attenuation Limit (dB)" 100
                    }
                  }
                ]
              }
              audio.rate = 48000
              audio.position = [MONO]
              capture.props = {
                node.passive = true
              }
              playback.props = {
                media.class = Audio/Source
              }
            }
          }
        ]
      '')
    ];
    services.pipewire.wireplumber.extraConfig = {
      "alsa-disable" = {
        monitor.alsa.rules = [
          {
            matches = [
              { "node.name" = "alsa_output.pci-0000_01_00.1.hdmi-stereo"; }
              {
                "node.name" = "alsa_output.usb-Blue_Microphones_Yeti_Nano_2209SG0034Y8_888-000469140106-00.analog-stereo";
              }
              { "node.name" = "alsa_input.pci-0000_34_00.6.analog-stereo"; }
              {
                "node.name" = "alsa_input.usb-Vimicro_Corp._Lenovo_FHD_Webcam_Lenovo_FHD_Webcam_Audio-02.analog-stereo";
              }
            ];
            actions.update-props = {
              "device.disabled" = true;
              "node.disabled" = true;
            };
          }
        ];
      };
    };
  };
}
