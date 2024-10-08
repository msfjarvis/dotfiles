{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.services.${namespace}.gitout;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;
in
{
  options.services.${namespace}.gitout = {
    enable = mkEnableOption { description = "Whether to enable the gitout backup service."; };

    config-file = mkOption {
      type = types.path;
      description = "Path to the gitout configuration file";
    };

    destination-dir = mkOption {
      type = types.str;
      description = "Path to the directory where the repositories are cloned to";
    };

    user = mkOption {
      type = types.str;
      default = "gitout";
      description = "User account under which gitout runs.";
    };

    group = mkOption {
      type = types.str;
      default = "gitout";
      description = "Group account under which gitout runs.";
    };

    package = mkPackageOption pkgs.jarvis "gitout" { };
  };

  config = mkIf cfg.enable {
    systemd.services.gitout = {
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
        exec env ${lib.getExe cfg.package} ${cfg.config-file} ${cfg.destination-dir}
      '';
    };

    systemd.timers.gitout = {
      description = "Run gitout every hour";
      timerConfig.OnCalendar = "hourly";
      wantedBy = [ "timers.target" ];
      partOf = [ "gitout.service" ];
    };

    users.users = mkIf (cfg.user == "gitout") {
      gitout = {
        inherit (cfg) group;
        home = cfg.dldir;
        createHome = false;
        description = "gitout daemon user";
        isNormalUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "gitout") {
      gitout = {
        gid = null;
      };
    };
  };
}
