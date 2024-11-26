{
  config,
  lib,
  pkgs,
  system,
  inputs,
  namespace,
  ...
}:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
  cfg = config.profiles.${namespace}.spotify;
  inherit (lib) mkEnableOption mkIf mkMerge;
in
{
  options.profiles.${namespace}.spotify = {
    enable = mkEnableOption "Enable Spotify";
    spot = mkEnableOption "Use Spot instead of the default client";
  };
  config = mkMerge [
    (mkIf (cfg.enable && !cfg.spot) {
      programs.spicetify = {
        enable = true;
        theme = spicePkgs.themes.catppuccin;
        colorScheme = "mocha";

        enabledCustomApps = with spicePkgs.apps; [ lyricsPlus ];

        enabledExtensions = with spicePkgs.extensions; [
          fullAppDisplay
          hidePodcasts
          lastfm
          showQueueDuration
          shuffle
        ];
      };
    })
    (mkIf (cfg.enable && cfg.spot) {
      home.packages = [ pkgs.${namespace}.spot-unstable ];
    })
  ];
}
