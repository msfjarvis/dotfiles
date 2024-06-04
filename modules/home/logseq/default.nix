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
  };
}
