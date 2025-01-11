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
        enabledSnippets = with spicePkgs.snippets; [
          disableRecommendations
          fixLikedButton
          fixMainViewWidth
          fixNowPlayingIcon
          hideAudiobooksButton
          hideDownloadButton
          hideFriendActivityButton
          hideFriendsActivityButton
          hideLikedSongsCard
          hideMadeForYou
          hidePlayingGif
          hidePodcastButton
          hideRecentlyPlayed
          hideWhatsNewButton
          modernScrollbar
          newHoverPanel
          removeEpLikes
          removeGradient
          removePopular
        ];
      };
    })
    (mkIf (cfg.enable && cfg.spot) {
      home.packages = [ pkgs.${namespace}.spot-unstable ];
    })
  ];
}
