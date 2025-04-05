{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.tandoor;
  domain = "tandoor.tiger-shark.ts.net";
  inherit (lib) mkEnableOption mkIf;
in
{
  options.services.${namespace}.tandoor = {
    enable = mkEnableOption "Enable the tandoor recipe service";
  };

  config = mkIf cfg.enable {
    sops.secrets.tandoor = {
      sopsFile = lib.snowfall.fs.get-file "secrets/tandoor.env";
      format = "dotenv";
      owner = config.services.tandoor-recipes.user;
      inherit (config.services.tandoor-recipes) group;
    };

    systemd.services.tandoor-recipes = {
      serviceConfig = {
        EnvironmentFile = [ config.sops.secrets.tandoor.path ];
      };
      after = [ "postgresql.service" ];
    };

    services.caddy.virtualHosts = {
      "${domain}" = {
        extraConfig = ''
          bind tailscale/tandoor
          reverse_proxy 127.0.0.1:${builtins.toString config.services.tandoor-recipes.port}
        '';
      };
    };

    services.prometheus.scrapeConfigs = [
      {
        job_name = "tandoor_recipes";
        static_configs = [
          {
            targets = [
              "${config.services.tandoor-recipes.address}:${toString config.services.tandoor-recipes.port}"
            ];
          }
        ];
      }
    ];

    services = {
      tandoor-recipes = {
        enable = true;
        port = 9007;
        extraConfig = {
          ALLOWED_HOSTS = domain;
          DB_ENGINE = "django.db.backends.postgresql";
          ENABLE_METRICS = 1;
          POSTGRES_HOST = "/run/postgresql";
          POSTGRES_USER = "tandoor_recipes";
          POSTGRES_DB = "tandoor_recipes";
          SOCIAL_DEFAULT_GROUP = "user";
        };
      };

      postgresql = {
        ensureDatabases = [ "tandoor_recipes" ];
        ensureUsers = [
          {
            name = "tandoor_recipes";
            ensureDBOwnership = true;
          }
        ];
      };
    };
  };
}
