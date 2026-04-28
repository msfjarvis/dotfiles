{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.deluge;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) ports;
in
{
  options.services.${namespace}.deluge = {
    enable = mkEnableOption "the Deluge Bittorrent client";
    tailnetDomain = mkOption {
      type = types.str;
      description = "Domain name to expose server on";
      default = null;
    };
  };
  config = mkIf cfg.enable {
    services.deluge = {
      enable = true;
      openFilesLimit = 8192;
      declarative = false;
      user = "msfjarvis";
      group = "users";

      web = {
        enable = true;
        port = ports.deluge-web;
      };
    };
  };
}
