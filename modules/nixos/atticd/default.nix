{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.atticd;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) mkTailscaleVHost ports tailnetDomain;
in
{
  options.services.${namespace}.atticd = {
    enable = mkEnableOption "attic binary cache";
    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Tailscale domain to expose the service on";
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts =
      { }
      // (mkIf (cfg.domain != null) (
        mkTailscaleVHost cfg.domain ''
          plausible {
            domain_name ${cfg.domain}.${tailnetDomain}
            base_url https://stats.msfjarvis.dev
          }
          reverse_proxy ${config.services.atticd.settings.listen}
        ''
      ));
    sops.secrets.atticd = {
      sopsFile = lib.snowfall.fs.get-file "secrets/atticd.yaml";
    };
    services.postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = "atticd";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "atticd" ];
    };
    services.atticd = {
      enable = true;
      package = pkgs.attic-server;
      environmentFile = config.sops.secrets.atticd.path;

      settings = {
        listen = "127.0.0.1:${toString ports.atticd}";
        database = {
          url = "postgres://atticd/atticd?host=/run/postgresql";
        };
        garbage-collection = {
          interval = "1 day";
          default-retention-period = "14 days";
        };
        storage = {
          type = "s3";
          region = "auto";
          bucket = "attic-cache";
          endpoint = "https://07d4cd9cc7e8077fcafc5dd2fc30391b.r2.cloudflarestorage.com";
        };
      };
    };
  };
}
