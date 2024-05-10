{
  config,
  lib,
  system,
  inputs,
  ...
}:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
  cfg = config.profiles.spotify;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.spotify = {
    enable = mkEnableOption "Enable Spotify";
  };
  config = mkIf cfg.enable {
    programs.spicetify = {
      enable = true;
      theme = spicePkgs.themes.dracula;

      enabledCustomApps = with spicePkgs.apps; [ lyrics-plus ];

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
