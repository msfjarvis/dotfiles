{
  config,
  lib,
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
    programs.goldwarden = {
      enable = true;
    };
  };
}
