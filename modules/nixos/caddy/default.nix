{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.caddy;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
  inherit (lib.${namespace}) mkSystemSecret;
in
{
  options.services.caddy = {
    applyDefaults = mkEnableOption { description = "apply the default settings for Caddy"; };
  };
  config = mkIf cfg.applyDefaults {
    sops.secrets.services-tsauthkey-env = mkSystemSecret {
      file = "tailscale";
      owner = config.services.caddy.user;
    };
    services.caddy = {
      enableReload = false; # I think caddy-tailscale breaks this
      package = pkgs.${namespace}.caddy-with-plugins;
      environmentFile = config.sops.secrets.services-tsauthkey-env.path;
      logFormat = ''
        output file /var/log/caddy/caddy_main.log {
          roll_size 100MiB
          roll_keep 5
          roll_keep_for 100d
        }
        format json
        level INFO
      '';
      globalConfig = ''
        servers {
          metrics
        }
        tailscale {
          ephemeral true
        }
        order plausible before reverse_proxy
      '';
      extraConfig = ''
        (blackholeCrawlers) {
          defender drop {
            ranges aliyun vpn aws deepseek githubcopilot gcloud azurepubliccloud openai mistral vultr digitalocean linode
          }
        }
      '';
    };
  };
}
