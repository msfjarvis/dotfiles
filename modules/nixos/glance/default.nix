{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.glance;
  settingsFormat = pkgs.formats.yaml { };
  settingsFile = settingsFormat.generate "glance.yaml" cfg.settings;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOptionMD
    types
    ;
  serverType = types.submodule {
    options = {
      host = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Host on which the Glance server listens.";
      };
      port = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = "Port on which the Glance server listens.";
      };
      assets-path = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to the assets directory.";
      };
    };
  };

  themeType = types.submodule {
    options = {
      light = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Whether to use the light theme.";
      };
      background-color = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Background color.";
      };
      primary-color = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Primary color.";
      };
      positive-color = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Positive color.";
      };
      negative-color = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Negative color.";
      };
      contrast-multiplier = mkOption {
        type = types.nullOr types.float;
        default = null;
        description = "Contrast multiplier.";
      };
      text-saturation-multiplier = mkOption {
        type = types.nullOr types.float;
        default = null;
        description = "Text saturation multiplier.";
      };
      custom-css-file = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to a custom CSS file.";
      };
    };
  };

  columnType = types.submodule {
    options = {
      size = mkOption {
        type = types.enum [
          "small"
          "full"
        ];
        default = "small";
        description = "Size of the column.";
      };
      # Ideally this would be a sum type of all possible widgets
      # but I cannot seem to make that work, so this is currently typed
      # as a list of attributes.
      widgets = mkOption {
        type = types.listOf types.attrs;
        default = [ ];
        description = "List of widgets to display in the column.";
      };
    };
  };

  commonWidgetType = types.submodule {
    options = {
      type = mkOption {
        # Sorted based on how they appear in the documentation, preserve this order
        # https://github.com/glanceapp/glance/blob/6de0f73ec1c8c02e97393714749d75d8823cb776/docs/configuration.md
        type = types.enum [
          "rss"
          "videos"
          "hacker-news"
          "reddit"
          "weather"
          "monitor"
          "repository"
          "bookmarks"
          "calendar"
          "stocks"
          "twitch-channels"
          "twitch-top-games"
          "iframe"
        ];
        description = "Type of widget.";
      };
      title = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Title of widget.";
      };
      cache = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Cache timeout for the widget's data source.";
      };
    };
  };

  # deadnix: skip
  rssWidgetType =
    commonWidgetType
    // types.submodule {
      options = {
        style = mkOption {
          type = types.nullOr types.enum [
            "horizontal-cards"
            "horizontal-cards-2"
            "vertical-list"
          ];
          default = null;
          description = "Layout type for the RSS widget.";
        };
        thumbnail-height = mkOption {
          type = types.nullOr types.float;
          default = null;
          description = "Height of thumbnails in `rem` units.";
        };
        card-height = mkOption {
          type = types.nullOr types.float;
          description = "Used to modify the height of cards when using the `horizontal-cards-2` style, in `rem` units.";
        };
        feeds = types.listOf (
          types.submodule {
            options = {
              url = mkOption {
                type = types.str;
                description = "URL of the RSS feed.";
              };
              title = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Defaults to the title provided by the feed.";
              };
            };
          }
        );
        limit = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "The maximum number of articles to show.";
        };
        collapse-after = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "How many articles are visible before the `SHOW MORE` button appears. Set to -1 to never collapse.";
        };
      };
    };

  # deadnix: skip
  videosWidgetType =
    commonWidgetType
    // types.submodule {
      channels = mkOption {
        type = types.listOf types.str;
        description = "A list of channel IDs.";
      };
      limit = mkOption {
        type = types.nullOr types.int;
        default = null;
        description = "The maximum number of videos to show.";
      };
      style = mkOption {
        type = types.nullOr types.enum [
          "horizontal-cards"
          "grid-cards"
        ];
        default = null;
        description = "Layout type for the videos widget.";
      };
      video-url-template = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "URL template for the video link.";
      };
    };

  # deadnix: skip
  hackerNewsWidgetType =
    commonWidgetType
    // types.submodule {
      options = {
        limit = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = "The maximum number of articles to show.";
        };
        collapse-after = mkOption {
          type = types.nullOr types.int;
          description = "How many articles are visible before the `SHOW MORE` button appears. Set to -1 to never collapse.";
        };
        comment-url-template = mkOption {
          type = types.nullOr types.str;
          description = "URL template for the comment link.";
        };
        sort-by = mkOption {
          type = types.nullOr types.enum [
            "top"
            "new"
            "best"
          ];
          description = "Sort order for the articles.";
        };
        extra-sort-by = mkOption {
          type = types.nullOr types.enum [ "engagement" ];
          description = "Can be used to specify an additional sort which will be applied on top of the already sorted posts";
        };
      };
    };

  pageType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Name of the page.";
      };

      slug = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Slug of the page.";
      };

      show-mobile-header = mkOption {
        type = types.nullOr types.bool;
        default = null;
        description = "Whether to show the mobile header.";
      };

      columns = mkOption {
        type = types.listOf columnType;
        description = "List of columns to display on the page.";
      };
    };
  };
in
{
  options.services.glance = {
    enable = mkEnableOption { description = "Whether to enable the Glance dashboard"; };

    settings = mkOption {
      type = types.submodule {
        options = {
          server = mkOption {
            type = serverType;
            description = "Server settings.";
          };
          theme = mkOption {
            type = themeType;
            description = "Theme settings.";
          };
          pages = mkOption {
            type = types.listOf pageType;
            default = [ ];
            description = "List of pages to display in the dashboard.";
          };
        };
      };
    };

    package = mkPackageOptionMD pkgs.jarvis "glance" { };

    user = mkOption {
      type = types.str;
      default = "glance";
      description = "User account under which Glance runs.";
    };

    group = mkOption {
      type = types.str;
      default = "glance";
      description = "Group account under which Glance runs.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.glance = {
      wantedBy = [ "default.target" ];
      after = [
        "fs.service"
        "networking.target"
      ];
      wants = [
        "fs.service"
        "networking.target"
      ];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        RestartSec = "30s";
        Type = "simple";
      };
      script = ''
        ${lib.getExe cfg.package} -config ${settingsFile}
      '';
    };

    users.users = mkIf (cfg.user == "glance") {
      glance = {
        inherit (cfg) group;
        createHome = false;
        description = "glance daemon user";
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "glance") {
      glance = {
        gid = null;
      };
    };
  };
}
