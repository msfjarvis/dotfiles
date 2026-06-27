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
      type = types.attrsOf (
        types.submodule {
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
            extraAuthorizationPolicy = mkOption {
              type = types.str;
              default = "";
              description = "Extra authorization policy directives to be prepended to the default values";
            };
          };
        }
      );
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
        servers {
          # Cloudflare proxy ranges from https://www.cloudflare.com/ips-v4 and https://www.cloudflare.com/ips-v6
          trusted_proxies static 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 104.24.0.0/14 172.64.0.0/13 131.0.72.0/22 2400:cb00::/32 2606:4700::/32 2803:f800::/32 2405:b500::/32 2405:8100::/32 2a06:98c0::/29 2c0f:f248::/32
          trusted_proxies_strict
          client_ip_headers CF-Connecting-IP CF-Connecting-IPv6 X-Forwarded-For
        }
        tailscale {
        }
        order authenticate before respond
        ${lib.optionalString (config.services.caddy.pocketIdApplications != { }) ''
          security {
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (name: app: ''
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
                  trust login redirect uri domain exact ${app.domain} path prefix /
                  cookie insecure off
                  transform user {
                    match realm ${name}
                    action add role authp/user
                  }
                }

                authorization policy ${name}_policy {
                  ${app.extraAuthorizationPolicy}
                  set auth url /caddy-security/oauth2/${name}
                  allow roles authp/user
                  inject headers with claims
                }
              '') config.services.caddy.pocketIdApplications
            )}
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
