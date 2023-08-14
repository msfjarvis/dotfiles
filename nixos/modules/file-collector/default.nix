{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.file-collector;
  settingsFormat = pkgs.formats.toml {};
  settingsFile = settingsFormat.generate "file-collector.toml" {bucket = {inherit (cfg) sources target file_filter;};};
in {
  options.services.file-collector = {
    enable = mkEnableOption {
      description = mdDoc "Whether to enable the file-collector daemon.";
    };

    sources = mkOption {
      type = types.listOf types.str;
      default = [];
      description = mdDoc "Directories to watch and pull files from";
    };

    target = mkOption {
      type = types.str;
      default = "";
      description = mdDoc "Directory to move files from source directories";
    };

    file_filter = mkOption {
      type = types.str;
      default = "";
      description = mdDoc "Shell glob to filter files against to be eligible for moving";
    };

    package = mkPackageOptionMD pkgs "file-collector" {};

    user = mkOption {
      type = types.str;
      default = "file-collector";
      description = mdDoc "User account under which file-collector runs.";
    };

    group = mkOption {
      type = types.str;
      default = "file-collector";
      description = mdDoc "Group account under which file-collector runs.";
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
