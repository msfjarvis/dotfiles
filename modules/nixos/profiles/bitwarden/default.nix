{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.profiles.${namespace}.bitwarden;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
in
{
  options.profiles.${namespace}.bitwarden = {
    enable = mkEnableOption "Bitwarden password manager";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (rbw.override { withFzf = true; })
      pinentry-curses
    ];
  };
}
