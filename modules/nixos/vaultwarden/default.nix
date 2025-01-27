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

    sops.secrets.vaultwarden = {
      sopsFile = lib.snowfall.fs.get-file "secrets/vaultwarden.env";
      owner = "vaultwarden";
      group = "vaultwarden";
      format = "dotenv";
    };
    services.vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      environmentFile = config.sops.secrets.vaultwarden.path;
      config = {
        DOMAIN = cfg.domain;
        EXPERIMENTAL_CLIENT_FEATURE_FLAGS = "autofill-v2,extension-refresh,fido2-vault-credentials,inline-menu-positioning-improvements,ssh-key-vault-item";
        SIGNUPS_ALLOWED = false;
        INVITATIONS_ALLOWED = false;
        ROCKET_PORT = 8890;
        DATABASE_URL = "postgres://vaultwarden?host=/run/postgresql";
      };
    };
  };
}
