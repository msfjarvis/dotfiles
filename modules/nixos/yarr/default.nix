{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.yarr;
in {
  options.services.yarr = {
    enable = mkEnableOption {
      description = mdDoc "Enable yarr: yet another rss reader.";
    };

    addr = mkOption {
      type = types.str;
      description = mdDoc "Network address to bind the yarr service to.";
    };

    auth-file = mkOption {
      type = types.str;
      description = mdDoc "Path to a file containing username:password.";
    };

    db = mkOption {
      type = types.str;
      description = mdDoc "Path to the SQLite database where yarr keeps its state.";
    };

    user = mkOption {
      type = types.str;
      default = "yarr";
      description = mdDoc "User account under which yarr runs.";
    };

    group = mkOption {
      type = types.str;
      default = "yarr";
      description = mdDoc "Group account under which yarr runs.";
    };

    package = mkPackageOptionMD pkgs "yarr" {};
  };

  config = mkIf cfg.enable {
    systemd.services.yarr = {
      wantedBy = ["default.target"];
      after = ["fs.service" "networking.target"];
      wants = ["fs.service" "networking.target"];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        RestartSec = "30s";
        Type = "oneshot";
      };
      script = "exec env ${getExe cfg.package} " + (builtins.concatStringsSep " " (builtins.map (opt: optionalString (cfg.${opt} != null) "-${opt} ${cfg.${opt}}") ["addr" "auth-file" "db"]));
    };

    users.users = mkIf (cfg.user == "yarr") {
      yarr = {
        inherit (cfg) group;
        createHome = false;
        description = "yarr daemon user";
        isNormalUser = true;
      };
    };

    users.groups =
      mkIf (cfg.group == "yarr") {yarr = {gid = null;};};
  };
}
