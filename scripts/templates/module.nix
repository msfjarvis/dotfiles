{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.MODULE_TYPE.${namespace}.MODULE_NAME;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.MODULE_TYPE.${namespace}.MODULE_NAME = {
    enable = mkEnableOption "MODULE_DESC";
  };
  config = mkIf cfg.enable { };
}
