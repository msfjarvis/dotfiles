{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.alps;
  alpsAddr = "127.0.0.1:${toString ports.alps}";
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  inherit (lib.${namespace}) ports tailnetDomain mkTailscaleVHost;
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
    systemd.services.alps = {
      after = [ "tailscaled-autoconnect.service" ];
      wants = [ "tailscaled-autoconnect.service" ];
    };

    services.caddy.virtualHosts = mkIf (cfg.domain != null) (
      mkTailscaleVHost cfg.domain ''
        reverse_proxy ${alpsAddr} {
          # Workaround for alps CSRF protection being a little wonky
          header_up -Origin
          header_up -Referer
        }
      ''
    );

    services.alps = {
      enable = true;
      package = pkgs.${namespace}.alps-purelymail;
      settings = {
        trusted_proxies = [
          "127.0.0.1/32"
          "::1/128"
          "10.0.0.0/8"
        ];
        server.addr = alpsAddr;
        plugins = {
          caldav = {
            server = "https://purelymail.com/webdav/322/caldav/";
          };
          carddav = {
            server = "https://purelymail.com/webdav/322/carddav/";
          };
          managesieve = {
            server = "managesieves://mailserver.purelymail.com:4190";
          };
        };
        provider.imap.server = "imaps://imap.purelymail.com:993";
        smtp.server = "smtps://smtp.purelymail.com:465";
        webauthn = {
          rpid = "${cfg.domain}.${tailnetDomain}";
          display_name = "Alps Webmail";
          origins = [ "https://${cfg.domain}.${tailnetDomain}/" ];
        };
      };
    };
  };
}
