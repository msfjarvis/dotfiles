{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.file-collector;
  settingsFormat = pkgs.formats.toml {};
  settingsFile = settingsFormat.generate "file-collector.toml" cfg.settings;
in {
  options.services.file-collector = {
    enable = mkEnableOption {
      description = mdDoc ''
        Whether to enable the file-collector daemon.
      '';
    };

    settings = mkOption {
      default = {};
    };

    package = mkPackageOptionMD pkgs "file-collector" {};

    user = mkOption {
      type = types.str;
      default = "file-collector";
      description = lib.mdDoc "User account under which file-collector runs.";
    };

    group = mkOption {
      type = types.str;
      default = "file-collector";
      description = lib.mdDoc "Group account under which file-collector runs.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.file-collector = {
      wantedBy = ["default.target"];
      after = ["fs.service"];
      wants = ["fs.service"];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        RestartSec = "30s";
        Type = "simple";
        Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.watchman}/bin";
      };
      script = ''
        exec env FILE_COLLECTOR_CONFIG=${settingsFile} ${pkgs.file-collector}/bin/file-collector
      '';
    };
  };
}
