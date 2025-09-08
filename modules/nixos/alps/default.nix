{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.alps;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  inherit (lib.${namespace}) ports mkTailscaleVHost;
in
{
  options.services.${namespace}.alps = {
    enable = mkEnableOption "alps webmail";
    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Tailscale domain to expose this on";
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts =
      { }
      // (mkIf (cfg.domain != null) (
        mkTailscaleVHost cfg.domain ''
          reverse_proxy ${config.services.alps.bindIP}:${toString config.services.alps.port}
        ''
      ));

    services.alps = {
      enable = true;
      port = ports.alps;
      bindIP = "127.0.0.1";
      theme = "sourcehut";
      imaps = {
        port = 993;
        host = "imap.purelymail.com";
      };
      smtps = {
        port = 465;
        host = "smtp.purelymail.com";
      };
    };
  };
}
