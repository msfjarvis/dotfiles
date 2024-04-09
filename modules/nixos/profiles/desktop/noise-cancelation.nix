{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.profiles.desktop;
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
                "plugin" = "${pkgs.jarvis.rnnoise-plugin-slim}/lib/ladspa/librnnoise_ladspa.so";
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
    services.pipewire.extraConfig.pipewire = pw_rnnoise_config;
  };
}
