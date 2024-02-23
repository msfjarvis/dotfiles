{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.desktop;
  json = pkgs.formats.json {};
  pw_rnnoise_config = {
    "context.modules" = [
      {
        "name" = "libpipewire-module-filter-chain";
        "args" = {
          "node.description" = "Noise Canceling source";
          "media.name" = "Noise Canceling source";
          "filter.graph" = {
            "nodes" = [
              {
                "type" = "ladspa";
                "name" = "rnnoise";
                "plugin" = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                "label" = "noise_suppressor_stereo";
                "control" = {
                  "VAD Threshold (%)" = 50.0;
                };
              }
            ];
          };
          "audio.position" = ["FL" "FR"];
          "capture.props" = {
            "node.name" = "effect_input.rnnoise";
            "node.passive" = true;
          };
          "playback.props" = {
            "node.name" = "effect_output.rnnoise";
            "media.class" = "Audio/Source";
          };
        };
      }
    ];
  };
in {
  options.profiles.desktop.noise-cancelation = with lib; {
    enable = mkEnableOption "Enable noise cancelation in PipeWire";
  };
  config = lib.mkIf cfg.noise-cancelation.enable {
    environment.etc."pipewire/pipewire.conf.d/99-input-denoising.conf" = {
      source = json.generate "99-input-denoising.conf" pw_rnnoise_config;
    };
  };
}
