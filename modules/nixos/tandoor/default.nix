{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.tandoor;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) ports;
  inherit (lib.${namespace}) mkSystemSecret;
in
{
  options.services.${namespace}.tandoor = {
    enable = mkEnableOption "Tandoor recipe service";
    domain = mkOption {
      type = types.str;
      description = "domain to expose Tandoor under";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.tandoor = mkSystemSecret {
      file = "tandoor";
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
      "https://${cfg.domain}" = {
        extraConfig = ''
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
        address = "127.0.0.1";
        port = ports.tandoor;
        database.createLocally = true;
        extraConfig = {
          ALLOWED_HOSTS = "127.0.0.1";
          ENABLE_METRICS = 1;
          SOCIAL_DEFAULT_GROUP = "user";
        };
      };
    };
  };
}
