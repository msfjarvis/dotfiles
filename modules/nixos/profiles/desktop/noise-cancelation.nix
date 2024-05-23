{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.desktop;
  inherit (lib) mkEnableOption mkIf;
  noise-suppression-for-voice = pkgs.writeTextDir "share/pipewire/pipewire.conf.d/99-noise-cancellation.conf" ''
    context.modules = [
    {   name = libpipewire-module-filter-chain
        args = {
            node.description =  "Noise Canceling source"
            media.name =  "Noise Canceling source"
            filter.graph = {
                nodes = [
                    {
                        type = ladspa
                        name = rnnoise
                        plugin = ${
                          pkgs.${namespace}.rnnoise-plugin-slim
                        }/lib/ladspa/librnnoise_ladspa.so
                        label = noise_suppressor_mono
                        control = {
                            "VAD Threshold (%)" = 50.0
                        }
                    }
                ]
            }
            capture.props = {
                node.name =  "effect_input.rnnoise"
                node.passive = true
                audio.rate = 48000
            }
            playback.props = {
                node.name =  "effect_output.rnnoise"
                media.class = Audio/Source
                audio.rate = 48000
            }
        }
    }
    ]
  '';
in
{
  options.profiles.desktop.noise-cancelation = {
    enable = mkEnableOption "Enable noise cancelation in PipeWire";
  };
  config = mkIf cfg.noise-cancelation.enable {
    services.pipewire.configPackages = [ noise-suppression-for-voice ];
  };
}
