{
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) forEach mkEnableOption mkIf;
  cfg = config.profiles.${namespace}.desktop.gaming;
  homeDir = config.users.users.msfjarvis.home;
  minecraftInstances = [
    "Big Globe"
    "CraftMine"
    "Fabulously.Optimized.1.21.3"
    "Fabulously.Optimized.1.21.4"
  ];
  instancePath = name: "${homeDir}/Games/PrismLauncher/instances/${name}";
  prismLauncher = pkgs.prismlauncher.override {
    jdks = with pkgs; [
      openjdk23
      openjdk17
    ];
  };
in
{
  options.profiles.${namespace}.desktop.gaming.minecraft = {
    enable = mkEnableOption "the children yearn for the mines";
  };
  config = mkIf cfg.minecraft.enable {
    users.users.msfjarvis.packages = with pkgs; [
      mcaselector
      (pkgs.symlinkJoin {
        name = "prismlauncher-with-launchers";
        paths =
          [ prismLauncher ]
          ++ (forEach minecraftInstances (
            instance:
            (pkgs.makeDesktopItem {
              desktopName = instance;
              type = "Application";
              categories = [
                "Game"
                "ActionGame"
                "AdventureGame"
                "Simulation"
              ];
              exec = "${lib.getExe prismLauncher} --launch ${instance}";
              name = instance;
              icon = "${instancePath instance}/icon.png";
            })
          ));
      })
    ];

    services.restic.backups.minecraft = {
      initialize = true;
      repository = "rest:https://restic.tiger-shark.ts.net/";
      passwordFile = config.sops.secrets.restic_repo_password.path;

      paths = forEach minecraftInstances (name: "${instancePath name}/.minecraft");

      pruneOpts = [
        "--keep-daily 2"
        "--keep-weekly 1"
        "--keep-monthly 1"
      ];
    };

    services.${namespace}.rucksack = {
      sources = forEach minecraftInstances (name: "${instancePath name}/.minecraft/screenshots");
    };
  };
}
