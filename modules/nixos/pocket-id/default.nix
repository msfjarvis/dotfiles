{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.pocket-id;
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
in
{
  options.services.${namespace}.pocket-id = {
    enable = mkEnableOption "Enable the pocket-id OIDC provider";
    domain = mkOption {
      type = types.str;
      description = "Domain name to expose server on";
      default = "https://auth.msfjarvis.dev";
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "${cfg.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${config.services.pocket-id.settings.PORT}
        '';
      };
    };
    services.postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "pocket-id";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "pocket-id" ];
    };
    sops.secrets.pocket-id = {
      sopsFile = lib.snowfall.fs.get-file "secrets/pocket-id.env";
      owner = config.services.pocket-id.user;
      inherit (config.services.pocket-id) group;
      format = "dotenv";
    };
    services.pocket-id = {
      enable = true;
      environmentFile = config.sops.secrets.pocket-id.path;
      settings = {
        APP_URL = cfg.domain;
        DB_PROVIDER = "postgres";
        DB_CONNECTION_STRING = "postgres://pocket-id/pocket-id?host=/run/postgresql";
        METRICS_ENABLED = true;
        OTEL_METRICS_EXPORTER = "prometheus";
        PORT = toString lib.${namespace}.ports.pocket-id;
        TRUST_PROXY = true;
        UI_CONFIG_DISABLED = true;
      };
    };
    systemd.services.pocket-id.serviceConfig.RestrictAddressFamilies = lib.mkForce [
      "AF_INET"
      "AF_INET6"
      "AF_UNIX"
    ];
  };
}
