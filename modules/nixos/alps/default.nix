{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.alps;
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.${namespace}) ports;
in
{
  options.services.${namespace}.alps = {
    enable = mkEnableOption "alps webmail";
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "https://mail.tiger-shark.ts.net" = {
        extraConfig = ''
          bind tailscale/mail
          reverse_proxy ${config.services.alps.bindIP}:${toString config.services.alps.port}
        '';
      };
    };

    services.alps = {
      enable = true;
      port = ports.alps;
      bindIP = "127.0.0.1";
      theme = "alps";
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
