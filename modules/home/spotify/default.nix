{
  config,
  lib,
  pkgs,
  system,
  inputs,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
  cfg = config.profiles.spotify;
in {
  options.profiles.spotify = with lib; {
    enable = mkEnableOption "Enable Spotify";
  };
  config = lib.mkIf cfg.enable {
    programs.spicetify = {
      enable = true;
      theme = spicePkgs.themes.dracula;

      enabledCustomApps = with spicePkgs.apps; [
        lyrics-plus
      ];

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        hidePodcasts
        lastfm
        showQueueDuration
        shuffle
      ];
    };
  };
}
