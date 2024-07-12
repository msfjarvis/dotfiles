{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.logseq;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.logseq = {
    enable = mkEnableOption "Install logseq and configure git synchronization";
  };
  config = mkIf cfg.enable { home.packages = with pkgs; [ logseq ]; };
}
