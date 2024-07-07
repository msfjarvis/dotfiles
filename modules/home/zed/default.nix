{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.profiles.zed;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.zed = {
    enable = mkEnableOption "Enable zed editor (zed.dev)";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # So the Zed Nix extension can find it
      nixd
      zed-editor
    ];
  };
}
