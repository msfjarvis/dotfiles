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
