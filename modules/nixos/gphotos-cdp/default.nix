{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.gphotos-cdp;
in {
  options.services.gphotos-cdp = {
    enable = mkEnableOption {
      description = mdDoc "Whether to enable the gphotos-cdp backup service.";
    };

    session-dir = mkOption {
      type = types.str;
      description = mdDoc "Path to the Google Chrome user session directory";
    };

    dldir = mkOption {
      type = types.str;
      description = mdDoc "Path to the directory where the files are downloaded";
    };

    user = mkOption {
      type = types.str;
      default = "gphotos-cdp";
      description = mdDoc "User account under which gphotos-cdp runs.";
    };

    group = mkOption {
      type = types.str;
      default = "gphotos-cdp";
      description = mdDoc "Group account under which gphotos-cdp runs.";
    };

    package = mkPackageOptionMD pkgs.jarvis "gphotos-cdp" {};
  };

  config = mkIf cfg.enable {
    systemd.services.gphotos-cdp = {
      wantedBy = ["default.target"];
      after = ["fs.service" "networking.target"];
      wants = ["fs.service" "networking.target"];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        RestartSec = "30s";
        Type = "oneshot";
        Environment = "PATH=${makeBinPath [pkgs.coreutils pkgs.google-chrome]}";
      };
      script = ''
        exec env ${getExe cfg.package} -v -dev -headless -dldir ${cfg.dldir} -session-dir ${cfg.session-dir}
      '';
    };

    systemd.timers.gphotos-cdp = {
      description = "Run gphotos-cdp every day";
      timerConfig.OnCalendar = "daily";
      wantedBy = ["timers.target"];
      partOf = ["gphotos-cdp.service"];
    };

    users.users = mkIf (cfg.user == "gphotos-cdp") {
      gphotos-cdp = {
        inherit (cfg) group;
        home = cfg.dldir;
        createHome = false;
        description = "gphotos-cdp daemon user";
        isNormalUser = true;
      };
    };

    users.groups =
      mkIf (cfg.group == "gphotos-cdp") {gphotos-cdp = {gid = null;};};
  };
}
