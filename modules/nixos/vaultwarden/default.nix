{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.vaultwarden;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.${namespace}.vaultwarden = {
    enable = mkEnableOption "Vaultwarden";
    domain = mkOption {
      type = types.str;
      description = "Domain name to expose server on";
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "${cfg.domain}" = {
        extraConfig = ''
          bind tailscale/pass
          reverse_proxy 127.0.0.1:${builtins.toString config.services.vaultwarden.config.ROCKET_PORT}
        '';
      };
    };

    services.postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "vaultwarden";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "vaultwarden" ];
    };

    services.vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      config = {
        DOMAIN = cfg.domain;
        DISABLE_ADMIN_TOKEN = true; # Drop this if ever hosting on public domain
        SIGNUPS_ALLOWED = false;
        INVITATIONS_ALLOWED = false;
        ROCKET_PORT = 8890;
        DATABASE_URL = "postgres://vaultwarden?host=/run/postgresql";
      };
    };
  };
}
