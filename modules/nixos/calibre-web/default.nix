{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.calibre-web;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) ports;
in
{
  options.services.${namespace}.calibre-web = {
    enable = mkEnableOption "Calibre-web";
    domain = mkOption {
      type = types.str;
      description = "domain to expose the service on";
      default = "books.msfjarvis.dev";
    };
    port = mkOption {
      type = types.port;
      description = "port to bind to";
      default = ports.calibre-web;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.calibre-web-caddy-env = {
      sopsFile = lib.snowfall.fs.get-file "secrets/calibre-web.env";
      format = "dotenv";
      owner = config.services.caddy.user;
      restartUnits = [ "caddy.service" ];
    };

    services.caddy.pocketIdApplications."calibreweb" = {
      inherit (cfg) domain;
      clientIdEnvVar = "$CALIBRE_WEB_POCKET_ID_CLIENT_ID";
      clientSecretEnvVar = "$CALIBRE_WEB_POCKET_ID_CLIENT_SECRET";
    };

    services.caddy.virtualHosts."https://${cfg.domain}".extraConfig = ''
      handle /caddy-security/* {
        route {
          authenticate with calibreweb_portal
        }
      }

      @integrations {
        path /opds /opds/* /kobo /kobo/*
      }
      handle @integrations {
        reverse_proxy localhost:${toString cfg.port} {
          header_up X-Scheme https
          transport http {
            read_buffer 1024k
            write_buffer 1024k
          }
        }
      }

      handle {
        route {
          authorize with calibreweb_policy
          reverse_proxy localhost:${toString cfg.port} {
            header_up X-Scheme https
            transport http {
              read_buffer 1024k
              write_buffer 1024k
            }
          }
        }
      }
    '';

    systemd.services.caddy.serviceConfig.EnvironmentFile = [
      config.sops.secrets.calibre-web-caddy-env.path
    ];

    services.calibre-web = {
      enable = true;
      package = pkgs.calibre-web.overridePythonAttrs (old: {
        dependencies =
          old.dependencies
          ++ old.optional-dependencies.kobo
          ++ old.optional-dependencies.metadata
          ++ old.optional-dependencies.oauth;
      });
      listen.port = cfg.port;
      options = {
        calibreLibrary = "/var/lib/calibre-web/library";
        enableBookUploading = true;
        enableKepubify = true;
        reverseProxyAuth = {
          enable = true;
          header = "X-Token-User-Email";
        };
      };
    };
  };
}
