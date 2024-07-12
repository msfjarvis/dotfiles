{
  config,
  lib,
  system,
  inputs,
  namespace,
  ...
}:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
  cfg = config.profiles.${namespace}.spotify;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.spotify = {
    enable = mkEnableOption "Enable Spotify";
  };
  config = mkIf cfg.enable {
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
  };
}
