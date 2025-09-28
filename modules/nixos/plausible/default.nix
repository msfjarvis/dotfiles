{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.plausible;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) ports mkSystemSecret;
in
{
  options.services.${namespace}.plausible = {
    enable = mkEnableOption "plausible analytics service";
    domain = mkOption {
      type = types.str;
      description = "Domain name to expose server on";
      default = "stats.msfjarvis.dev";
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "https://${cfg.domain}" = {
        extraConfig = ''
          import blackholeCrawlers
          reverse_proxy ${config.services.plausible.server.listenAddress}:${toString config.services.plausible.server.port}
        '';
      };
    };

    sops.secrets.plausible-secret = mkSystemSecret {
      file = "plausible";
    };
    sops.secrets.plausible-smtp-pass = mkSystemSecret {
      file = "plausible";
    };
    services.plausible = {
      enable = true;
      database.clickhouse.url = "http://localhost:${toString ports.clickhouse.http}/default";
      server = {
        baseUrl = "https://${cfg.domain}";
        secretKeybaseFile = config.sops.secrets.plausible-secret.path;
      };
      mail = {
        email = "reports@${cfg.domain}";
        smtp = {
          enableSSL = true;
          hostAddr = "smtp.purelymail.com";
          hostPort = 587;
          passwordFile = config.sops.secrets.plausible-smtp-pass.path;
          user = "me@msfjarvis.dev";
        };
      };
    };
    # Force override the ports used by Clickhouse
    environment.etc."clickhouse-server/config.xml".source = lib.mkForce (
      pkgs.runCommandLocal "clickhouse-server-config.xml" { } ''
        cp "${config.services.clickhouse.package}/etc/clickhouse-server/config.xml" temp.xml
        substituteInPlace temp.xml \
          --replace-fail 8123 ${toString ports.clickhouse.http} \
          --replace-fail 9000 ${toString ports.clickhouse.tcp} \
          --replace-fail 9004 ${toString ports.clickhouse.mysql} \
          --replace-fail 9005 ${toString ports.clickhouse.postgresql} \
          --replace-fail 9009 ${toString ports.clickhouse.interserver_http}
        mv temp.xml $out
      ''
    );
  };
}
