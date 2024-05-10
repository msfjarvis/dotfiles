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
in
{
  options.services.glance = {
    enable = mkEnableOption { description = "Whether to enable the Glance dashboard"; };

    configFile = mkOption {
      type = types.str;
      example = "/etc/glance/glance.yaml";
      description = "Path to the Glance configuration file.";
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
