{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.rucksack;
  settingsFormat = pkgs.formats.toml {};
  settingsFile = settingsFormat.generate "rucksack.toml" {inherit (cfg) sources target file_filter;};
in {
  options.services.rucksack = {
    enable = mkEnableOption {
      description = mdDoc "Whether to enable the rucksack daemon.";
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

    package = mkPackageOptionMD pkgs.jarvis "rucksack" {};

    user = mkOption {
      type = types.str;
      default = "rucksack";
      description = mdDoc "User account under which rucksack runs.";
    };

    group = mkOption {
      type = types.str;
      default = "rucksack";
      description = mdDoc "Group account under which rucksack runs.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.rucksack = {
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
        exec env RUCKSACK_CONFIG=${settingsFile} ${lib.getExe cfg.package}
      '';
    };

    users.users = mkIf (cfg.user == "rucksack") {
      rucksack = {
        inherit (cfg) group;
        home = cfg.dataDir;
        createHome = false;
        description = "rucksack daemon user";
        isNormalUser = true;
      };
    };

    users.groups =
      mkIf (cfg.group == "rucksack") {rucksack = {gid = null;};};
  };
}
