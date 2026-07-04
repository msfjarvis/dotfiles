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
    mkMerge
    optional
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
    cloudflare.enable = mkEnableOption "Cloudflare edge bans for public web jails";
  };

  config = mkMerge [
    {
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
      }
      // lib.optionalAttrs cfg.cloudflare.enable {
        action = lib.concatStringsSep "\n" [
          "%(action_)s"
          "  cloudflare-edge-ban"
        ];
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
    }
    (mkIf cfg.cloudflare.enable {
      sops.secrets.cloudflare-fail2ban-token = {
        sopsFile = lib.snowfall.fs.get-file "secrets/cloudflare/fail2ban.yaml";
        format = "yaml";
        key = "token";
      };
      sops.secrets.cloudflare-fail2ban-zone-id = {
        sopsFile = lib.snowfall.fs.get-file "secrets/cloudflare/fail2ban.yaml";
        format = "yaml";
        key = "zone_id";
      };

      environment.etc."fail2ban/action.d/cloudflare-edge-ban.conf".text = ''
        [Definition]
        actionstart =
        actionstop =
        actioncheck =
        actionban = ${getExe pkgs.curl} -s -X POST "<_cf_api_url>" <_cf_api_prms> --data '{"mode":"<cfmode>","configuration":{"target":"<cftarget>","value":"<ip>"},"notes":"<notes>"}'
        actionunban = id=$(${getExe pkgs.curl} -s -G -X GET "<_cf_api_url>" --data-urlencode "mode=<cfmode>" --data-urlencode "notes=<notes>" --data-urlencode "configuration.target=<cftarget>" --data-urlencode "configuration.value=<ip>" <_cf_api_prms> | ${getExe pkgs.gawk} -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/"id"/){print $(i+1)}}}' | tr -d ' "' | head -n 1)
        	if [ -z "$id" ]; then echo "<name>: id for <ip> cannot be found using target <cftarget>"; exit 0; fi; \
        	${getExe pkgs.curl} -s -X DELETE "<_cf_api_url>/$id" <_cf_api_prms> --data '{"cascade": "none"}'
        _cf_api_url = https://api.cloudflare.com/client/v4/zones/$(cat <zoneidfile>)/firewall/access_rules/rules
        _cf_api_prms = -H "Authorization: Bearer $(cat <tokenfile>)" -H "Content-Type: application/json"

        [Init]
        cftarget = ip
        cfmode = block
        notes = Fail2Ban <name>
        tokenfile = ${config.sops.secrets.cloudflare-fail2ban-token.path}
        zoneidfile = ${config.sops.secrets.cloudflare-fail2ban-zone-id.path}

        [Init?family=inet6]
        cftarget = ip6
      '';
    })
    (mkIf prometheusEnabled {
      services.prometheus.scrapeConfigs = [
        {
          job_name = "fail2ban";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.fail2ban.port}" ];
            }
          ];
        }
      ];
    })
  ];
}
