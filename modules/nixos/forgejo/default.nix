{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.forgejo;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (lib.${namespace}) ports;
in
{
  options.services.${namespace}.forgejo = {
    enable = mkEnableOption "Forgejo Git hosting server";
    domain = mkOption {
      type = types.str;
      description = "Domain name to expose server on";
    };
  };
  config = mkIf cfg.enable {
    environment.etc."fail2ban/filter.d/caddy-forgejo-404.local".text = ''
      [Definition]
      failregex = ^<HOST>.*"[A-Z]+ .*" 404[ \d]*$
      ignoreregex =
    '';

    sops.secrets."cloudflared/forgejo" = {
      sopsFile = lib.snowfall.fs.get-file "secrets/cloudflare/forgejo-tunnel-creds.bin";
      format = "binary";
    };
    services.cloudflared = {
      enable = false;
      tunnels."44b1dcda-66b1-49bf-b939-80193c0b0198" = {
        credentialsFile = config.sops.secrets."cloudflared/forgejo".path;
        default = "http_status:404";
        ingress = {
          "git.msfjarvis.dev" =
            with config.services.forgejo.settings.server;
            "http://${HTTP_ADDR}:${toString HTTP_PORT}";
        };
      };
    };
    services.caddy.virtualHosts = {
      "https://${cfg.domain}" = {
        logFormat = lib.${namespace}.mkFail2banLogFormat cfg.domain;
        extraConfig = with config.services.forgejo.settings.server; ''
          import blackholeCrawlers
          reverse_proxy ${HTTP_ADDR}:${toString HTTP_PORT} {
            header_up X-Forwarded-For {http.request.header.CF-Connecting-IP}
          }
        '';
      };
      "https://vibes.msfjarvis.dev" = {
        logFormat = lib.${namespace}.mkFail2banLogFormat "vibes.msfjarvis.dev";
        extraConfig = ''
          gitea_pages {
            gitea_url https://${cfg.domain}
            domain_mapping vibes.msfjarvis.dev msfjarvis acceptable-vibes
            cache_ttl 15m
          }
        '';
      };
    };
    services.fail2ban.jails.caddy-forgejo-404.settings = {
      enabled = true;
      filter = "caddy-forgejo-404";
      logpath = "/var/log/caddy/access-${cfg.domain}.log";
      backend = "auto";
      port = "http,https";
      findtime = 1;
      maxretry = 1;
      bantime = 2592000;
    };
    services.prometheus.scrapeConfigs = [
      {
        job_name = "forgejo";
        static_configs = [
          {
            targets = with config.services.forgejo.settings.server; [ "${HTTP_ADDR}:${toString HTTP_PORT}" ];
          }
        ];
      }
    ];
    services.forgejo = {
      enable = true;
      package = pkgs.forgejo;
      database = {
        type = "postgres";
        createDatabase = true;
      };
      dump = {
        enable = true;
        type = "tar.zst";
      };
      settings = {
        DEFAULT = {
          APP_NAME = "Harsh Shandilya's Git hosting";
        };
        api = {
          ENABLE_SWAGGER = false;
        };
        "cron.update_mirrors" = {
          PULL_LIMIT = -1;
        };
        "cron.delete_repo_archives" = {
          ENABLED = true;
          SCHEDULE = "@daily";
        };
        "cron.git_gc_repos" = {
          ENABLED = true;
          ARGS = "--aggressive --auto";
        };
        "cron.update_checker" = {
          ENABLED = false;
        };
        federation = {
          ENABLED = true;
        };
        git = {
          GC_ARGS = "--aggressive --auto";
        };
        "git.config" = {
          "diff.algorithm" = "patience";
        };
        indexer = {
          REPO_INDEXER_ENABLED = true;
          REPO_INDEXER_PATH = "indexers/repos.bleve";
          MAX_FILE_SIZE = 1048576;
          REPO_INDEXER_EXCLUDE = "resources/bin/**";
        };
        mailer = {
          ENABLED = false;
        };
        metrics = {
          ENABLED = true;
        };
        mirror = {
          DEFAULT_INTERVAL = "1h";
        };
        oauth2 = {
          # Increase token expiry to one day as a workaround for GCM
          # handling token refresh poorly. Refs:
          # - https://forum.gitea.com/t/authentication-failed-for-but-running-the-command-again-works/8521
          # - https://github.com/git-ecosystem/git-credential-manager/issues/1408
          # - https://github.com/go-gitea/gitea/issues/31470
          ACCESS_TOKEN_EXPIRATION_TIME = 86400;
        };
        other = {
          SHOW_FOOTER_POWERED_BY = false;
        };
        repository = {
          DISABLE_HTTP_GIT = false;
          DISABLE_STARS = true;
          ENABLE_PUSH_CREATE_USER = true;
          DISABLE_DOWNLOAD_SOURCE_ARCHIVES = true;
        };
        "repository.pull-request" = {
          DEFAULT_MERGE_STYLE = "rebase";
          DEFAULT_MERGE_MESSAGE_ALL_AUTHORS = true;
        };
        server = {
          DISABLE_SSH = true;
          DOMAIN = "${cfg.domain}";
          ENABLE_GZIP = true;
          LANDING_PAGE = "explore";
          ROOT_URL = "https://${cfg.domain}/";
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = ports.forgejo;
        };
        service = {
          DISABLE_REGISTRATION = true;
        };
        session = {
          COOKIE_NAME = "i_dont_like_gitea";
          COOKIE_SECURE = true;
          DOMAIN = cfg.domain;
        };
        time = {
          DEFAULT_UI_LOCATION = "Asia/Kolkata";
        };
        ui = {
          THEMES = builtins.concatStringsSep "," (
            [ "auto" ]
            ++ (map (name: lib.removePrefix "theme-" (lib.removeSuffix ".css" name)) (
              builtins.attrNames (builtins.readDir "${pkgs.${namespace}.catppuccin-gitea}")
            ))
          );
          DEFAULT_THEME = "catppuccin-mocha-mauve";
          DEFAULT_SHOW_FULL_NAME = true;
        };
        "ui.meta" = {
          AUTHOR = "Harsh Shandilya";
          DESCRIPTION = "Harsh Shandilya's personal Git repositories";
          KEYWORDS = "msfjarvis,msfjarvis github,harsh shandilya, harsh shandilya github";
        };
      };
    };
    systemd.services.forgejo = {
      preStart =
        let
          inherit (config.services.forgejo) stateDir;
        in
        lib.mkAfter ''
          rm -rf ${stateDir}/custom/public/assets/css
          mkdir -p ${stateDir}/custom/public/assets/
          ln -sfn ${pkgs.${namespace}.catppuccin-gitea} ${stateDir}/custom/public/assets/css
        '';
    };
  };
}
