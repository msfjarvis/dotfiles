{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  cfg = config.services.${namespace}.fail2ban;
  exporterCfg = config.services.prometheus.exporters.fail2ban;
  inherit (lib)
    concatStringsSep
    getExe
    mkEnableOption
    mkIf
    optional
    optionals
    ;
  inherit (lib.${namespace}) ports;
  prometheusEnabled = config.services.${namespace}.prometheus.enable;
  exporterArgs = concatStringsSep " \\\n            " (
    [
      (getExe pkgs.prometheus-fail2ban-exporter)
    ]
    ++ optional exporterCfg.exitOnError "--collector.f2b.exit-on-socket-connection-error"
    ++ optional (exporterCfg.username != null) ''--web.basic-auth.username="${exporterCfg.username}"''
    ++ optional (
      exporterCfg.passwordFile != null
    ) ''--web.basic-auth.password="$(cat ${exporterCfg.passwordFile})"''
    ++ [
      ''--web.listen-address="${exporterCfg.host}:${toString exporterCfg.port}"''
      "--collector.f2b.socket=${exporterCfg.fail2banSocket}"
    ]
  );
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

    systemd.services.prometheus-fail2ban-exporter = mkIf exporterCfg.enable {
      requires = mkIf config.services.fail2ban.enable [ "prometheus-fail2ban-exporter-setup.service" ];
      serviceConfig = {
        DynamicUser = false;
        ExecStart = lib.mkForce ''
          ${exporterArgs}
        '';
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
      };
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
