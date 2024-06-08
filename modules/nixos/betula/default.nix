{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.betula;
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOptionMD
    types
    ;
in
{
  options.services.betula = {
    enable = mkEnableOption { description = "Whether to enable the betula bookmarking service."; };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/betula/";
      description = "Path to the directory where betula will persist its state.";
    };

    user = mkOption {
      type = types.str;
      default = "betula";
      description = "User account under which betula runs.";
    };

    group = mkOption {
      type = types.str;
      default = "betula";
      description = "Group account under which betula runs.";
    };

    package = mkPackageOptionMD pkgs "betula" { };
  };

  config = mkIf cfg.enable {
    systemd.services.betula = {
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
        Type = "simple";
      };
      script = ''
        ${lib.getExe cfg.package} ${cfg.dataDir}/sqlite.db
      '';
    };

    systemd.tmpfiles.rules = [ "d ${cfg.dataDir} 0755 ${cfg.user} ${cfg.group} - -" ];

    users.users = mkIf (cfg.user == "betula") {
      betula = {
        inherit (cfg) group;
        createHome = false;
        description = "betula daemon user";
        isNormalUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "betula") { betula = { }; };
  };
}
