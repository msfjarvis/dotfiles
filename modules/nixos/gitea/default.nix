{
  config,
  lib,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.gitea;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
in
{
  options.services.${namespace}.gitea = {
    enable = mkEnableOption "Gitea Git hosting server";
    domain = mkOption {
      type = types.str;
      description = "Domain name to expose server on";
    };
  };
  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "https://${cfg.domain}" = {
        extraConfig = ''
          import blackholeCrawlers
          reverse_proxy 127.0.0.1:${toString config.services.gitea.settings.server.HTTP_PORT}
          log {
            output file /var/log/caddy/caddy_${cfg.domain}.log {
              roll_size 100MiB
              roll_keep 5
              roll_keep_for 100d
            }
            format json
            level INFO
          }
        '';
      };
    };
    services.gitea = {
      enable = true;
      appName = "Harsh Shandilya's Git hosting";
      settings = {
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
        "git.config" = {
          "diff.algorithm" = "patience";
        };
        indexer = {
          REPO_INDEXER_ENABLED = true;
          REPO_INDEXER_PATH = "ndexers/repos.bleve";
          MAX_FILE_SIZE = 1048576;
          REPO_INDEXER_EXCLUDE = "resources/bin/**";
        };
        mailer = {
          ENABLED = false;
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
          DISABLE_HTTP_GIT = true;
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
        };
        service = {
          COOKIE_SECURE = true;
          DISABLE_REGISTRATION = true;
        };
        time = {
          DEFAULT_UI_LOCATION = "Asia/Kolkata";
        };
        ui = {
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

  };
}
