{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.glance;
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
        description = "Host on which the Glance server listens.";
      };
      port = mkOption {
        type = types.nullOr types.port;
        description = "Port on which the Glance server listens.";
      };
      assets-path = mkOption {
        type = types.nullOr types.str;
        description = "Path to the assets directory.";
      };
    };
  };

  themeType = types.submodule {
    options = {
      light = mkOption {
        type = types.nullOr types.bool;
        description = "Whether to use the light theme.";
      };
      background-color = mkOption {
        type = types.nullOr types.str;
        description = "Background color.";
      };
      primary-color = mkOption {
        type = types.nullOr types.str;
        description = "Primary color.";
      };
      positive-color = mkOption {
        type = types.nullOr types.str;
        description = "Positive color.";
      };
      negative-color = mkOption {
        type = types.nullOr types.str;
        description = "Negative color.";
      };
      contrast-multiplier = mkOption {
        type = types.nullOr types.float;
        description = "Contrast multiplier.";
      };
      text-saturation-multiplier = mkOption {
        type = types.nullOr types.float;
        description = "Text saturation multiplier.";
      };
      custom-css-file = mkOption {
        type = types.nullOr types.str;
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
        description = "Size of the column.";
      };
      widgets = mkOption {
        type = types.list types.enum (
          map types.attrsOf [
            rssWidgetType
            videosWidgetType
            hackerNewsWidgetType
          ]
        );
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
        description = "Title of widget.";
      };
      cache = mkOption {
        type = types.nullOr types.str;
        description = "Cache timeout for the widget's data source.";
      };
    };
  };

  rssWidgetType = types.submodule {
    options = {
      style = mkOption {
        type = types.nullOr types.enum [
          "horizontal-cards"
          "horizontal-cards-2"
          "vertical-list"
        ];
        description = "Layout type for the RSS widget.";
      };
      thumbnail-height = mkOption {
        type = types.nullOr types.float;
        description = "Height of thumbnails in `rem` units.";
      };
      card-height = mkOption {
        type = types.nullOr types.float;
        description = "Used to modify the height of cards when using the `horizontal-cards-2` style, in `rem` units.";
      };
      feeds = types.list types.submodule {
        options = {
          url = mkOption {
            type = types.str;
            description = "URL of the RSS feed.";
          };
          title = mkOption {
            type = types.nullOr types.str;
            description = "Defaults to the title provided by the feed.";
          };
        };
      };
      limit = mkOption {
        type = types.nullOr types.int;
        description = "The maximum number of articles to show.";
      };
      collapse-after = mkOption {
        type = types.nullOr types.int;
        description = "How many articles are visible before the `SHOW MORE` button appears. Set to -1 to never collapse.";
      };
    };
  };

  videosWidgetType = types.submodule {
    channels = mkOption {
      type = types.list types.str;
      description = "A list of channel IDs.";
    };
    limit = mkOption {
      type = types.nullOr types.int;
      description = "The maximum number of videos to show.";
    };
    style = mkOption {
      type = types.nullOr types.enum [
        "horizontal-cards"
        "grid-cards"
      ];
      description = "Layout type for the videos widget.";
    };
    video-url-template = mkOption {
      type = types.nullOr types.str;
      description = "URL template for the video link.";
    };
  };

  hackerNewsWidgetType = types.submodule {
    options = {
      limit = mkOption {
        type = types.nullOr types.int;
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
        type = types.str;
        description = "Slug of the page.";
      };

      show-mobile-header = mkOption {
        type = types.nullOr types.bool;
        description = "Whether to show the mobile header.";
      };

      columns = mkOption {
        type = types.list columnType;
        description = "List of columns to display on the page.";
      };
    };
  };
in
{
  options.services.glance = {
    enable = mkEnableOption { description = "Whether to enable the Glance dashboard"; };

    configFile = mkOption {
      type = types.str;
      example = "/etc/glance/glance.yaml";
      description = "Path to the Glance configuration file.";
    };

    settings = mkOption {
      type = types.submodule {
        options = {
          server = serverType;
          theme = themeType;
          pages = mkOption {
            type = types.list pageType;
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
        ${lib.getExe cfg.package} -config ${cfg.configFile}
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
