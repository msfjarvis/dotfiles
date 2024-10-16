{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.bitwarden;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.profiles.${namespace}.bitwarden = {
    enable = mkEnableOption "Bitwarden CLI and git credential helper";
  };
  config = mkIf cfg.enable {
    programs.rbw = {
      enable = true;
      package = pkgs.rbw.override { withFzf = true; };
      settings = {
        email = "me@msfjarvis.dev";
        base_url = "https://pass.tiger-shark.ts.net";
        pinentry = pkgs.pinentry-gnome3;
      };
    };
  };
}
