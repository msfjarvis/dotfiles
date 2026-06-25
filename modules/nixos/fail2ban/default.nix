{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.fail2ban;
  inherit (lib)
    mkEnableOption
    mkIf
    optionals
    ;
  inherit (lib.${namespace}) ports;
  prometheusEnabled = config.services.${namespace}.prometheus.enable;
in
{
  options.services.${namespace}.fail2ban = {
    enable = mkEnableOption "fail2ban defaults";
  };

  config = mkIf cfg.enable {
    services.fail2ban.enable = true;

    environment.etc."fail2ban/filter.d/caddy-access.local".text = ''
      [Definition]
      failregex = ^<HOST>.*"(GET|POST|OPTIONS).*" (4[0-9][0-9])[ \d]*$
      ignoreregex =
    '';

    services.fail2ban.jails.caddy-access.settings = {
      enabled = true;
      filter = "caddy-access";
      logpath = "/var/log/caddy/access-*.log";
      backend = "auto";
      port = "http,https";
      findtime = 30;
      maxretry = 5;
      bantime = 600;
    };

    services.prometheus.exporters.fail2ban = {
      enable = true;
      host = "127.0.0.1";
      port = ports.exporters.fail2ban;
    };

    services.prometheus.scrapeConfigs = optionals prometheusEnabled [
      {
        job_name = "fail2ban";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.fail2ban.port}" ];
          }
        ];
      }
    ];
  };
}
