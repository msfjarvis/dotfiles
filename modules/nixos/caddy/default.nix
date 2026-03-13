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
    mkOption
    types
    ;
in
{
  options.services.caddy = {
    applyDefaults = mkEnableOption { description = "apply the default settings for Caddy"; };
    pocketIdApplications = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          domain = mkOption {
            type = types.str;
            description = "Domain of the proxied service";
          };
          clientIdEnvVar = mkOption {
            type = types.str;
            description = "Environment variable name containing the client ID";
          };
          clientSecretEnvVar = mkOption {
            type = types.str;
            description = "Environment variable name containing the client secret";
          };
        };
      });
      default = { };
      description = "Applications to protect with Pocket ID OIDC via caddy-security";
    };
  };
  config = mkIf cfg.applyDefaults {
    systemd.services.caddy = {
      after = [ "tailscaled-autoconnect.service" ];
      wants = [ "tailscaled-autoconnect.service" ];
    };

    sops.secrets.services-oauth-secret-env = {
      sopsFile = lib.snowfall.fs.get-file "secrets/tailscale.yaml";
      owner = config.services.caddy.user;
    };
    services.caddy = {
      enableReload = false; # I think caddy-tailscale breaks this
      package = pkgs.${namespace}.caddy-with-plugins;
      environmentFile = config.sops.secrets.services-oauth-secret-env.path;
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
        metrics
        tailscale {
          ephemeral true
        }
        order authenticate before respond
        ${lib.optionalString (config.services.caddy.pocketIdApplications != { }) ''
          security {
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: app: ''
              oauth identity provider ${name} {
                delay_start 3
                realm ${name}
                driver generic
                client_id {${app.clientIdEnvVar}}
                client_secret {${app.clientSecretEnvVar}}
                scopes openid email profile
                base_auth_url https://auth.msfjarvis.dev
                metadata_url https://auth.msfjarvis.dev/.well-known/openid-configuration
              }

              authentication portal ${name}_portal {
                crypto default token lifetime 3600
                enable identity provider ${name}
                cookie insecure off
                cookie domain ${app.domain}
                transform user {
                  match realm ${name}
                  action add role user
                }
              }

              authorization policy ${name}_policy {
                set auth url /caddy-security/oauth2/${name}
                allow roles user
                inject headers with claims
              }
            '') config.services.caddy.pocketIdApplications)}
          }
        ''}
      '';
      extraConfig = ''
        (blackholeCrawlers) {
          defender drop {
            ranges aliyun vpn aws deepseek githubcopilot gcloud azurepubliccloud openai mistral vultr digitalocean linode huawei
          }
        }
      '';
    };
  };
}
