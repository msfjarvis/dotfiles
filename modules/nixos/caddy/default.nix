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
    environment.etc."fail2ban/filter.d/caddy-access.local".text = ''
      [Definition]
      failregex = ^<HOST>.*"(GET|POST|OPTIONS).*" (4[0-9][0-9])[ \d]*$
      ignoreregex =
    '';
    environment.etc."fail2ban/filter.d/caddy-git-404.local".text = ''
      [Definition]
      failregex = ^<HOST>.*"[A-Z]+ .*" 404[ \d]*$
      ignoreregex =
    '';

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

    services.fail2ban.jails.caddy-access.settings = {
      enabled = true;
      filter = "caddy-access";
      logpath = "/var/log/caddy/access-*.log";
      backend = "auto";
      port = "http,https";
      findtime = 30;
      maxretry = 5;
      bantime = 600;
    };

    services.fail2ban.jails.caddy-git-404.settings = {
      enabled = true;
      filter = "caddy-git-404";
      logpath = "/var/log/caddy/access-git.msfjarvis.dev.log";
      backend = "auto";
      port = "http,https";
      findtime = 1;
      maxretry = 1;
      bantime = 2592000;
    };
  };
}
