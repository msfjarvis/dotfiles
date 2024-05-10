{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.gphotos-cdp;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOptionMD
    types
    ;
in
{
  options.services.gphotos-cdp = {
    enable = mkEnableOption { description = "Whether to enable the gphotos-cdp backup service."; };

    session-dir = mkOption {
      type = types.str;
      description = "Path to the Google Chrome user session directory";
    };

    dldir = mkOption {
      type = types.str;
      description = "Path to the directory where the files are downloaded";
    };

    user = mkOption {
      type = types.str;
      default = "gphotos-cdp";
      description = "User account under which gphotos-cdp runs.";
    };

    group = mkOption {
      type = types.str;
      default = "gphotos-cdp";
      description = "Group account under which gphotos-cdp runs.";
    };

    package = mkPackageOptionMD pkgs.jarvis "gphotos-cdp" { };
  };

  config = mkIf cfg.enable {
    systemd.services.gphotos-cdp = {
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
        Type = "oneshot";
        Environment = "PATH=${
          lib.makeBinPath [
            pkgs.coreutils
            pkgs.google-chrome
          ]
        }";
      };
      script = ''
        exec env ${lib.getExe cfg.package} -v -dev -headless -dldir ${cfg.dldir} -session-dir ${cfg.session-dir}
      '';
    };

    systemd.timers.gphotos-cdp = {
      description = "Run gphotos-cdp every day";
      timerConfig.OnBootSec = "15min";
      wantedBy = [ "timers.target" ];
      partOf = [ "gphotos-cdp.service" ];
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

    users.groups = mkIf (cfg.group == "gphotos-cdp") {
      gphotos-cdp = {
        gid = null;
      };
    };
  };
}
