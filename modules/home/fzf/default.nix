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
      fileWidget.command = "fd -H";
      changeDirWidget.command = "fd -Htd";
      historyWidget = {
        command = "";
        options = [
          "--sort"
          "--exact"
        ];
      };
    };
  }
  (lib.optionalAttrs stylixAvailable {
    stylix.targets.fzf.enable = true;
  })
]
