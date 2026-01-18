{
  lib,
  options,
  ...
}:
let
  stylixAvailable = options ? stylix.targets;
in
lib.mkMerge [
  {
    programs.fzf = {
      enable = true;
      defaultCommand = "fd -tf";
      defaultOptions = [ "--height 40%" ];
      enableBashIntegration = true;
      fileWidgetCommand = "fd -H";
      changeDirWidgetCommand = "fd -Htd";
      historyWidgetOptions = [
        "--sort"
        "--exact"
      ];
    };
  }
  (lib.optionalAttrs stylixAvailable {
    stylix.targets.fzf.enable = true;
  })
]
