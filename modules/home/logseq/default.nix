{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.profiles.logseq;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.logseq = {
    enable = mkEnableOption "Install logseq and configure git synchronization";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ logseq ];
    services.git-sync = {
      enable = true;
      repositories = {
        logseq = {
          path = "${config.home.homeDirectory}/logseq";
          uri = "git+ssh://msfjarvis@github.com:msfjarvis/logseq-backup.git";
          interval = 600;
        };
      };
    };
  };
}
