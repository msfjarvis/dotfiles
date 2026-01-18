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
    programs.bat.enable = true;
  }
  (lib.optionalAttrs stylixAvailable {
    stylix.targets.bat.enable = true;
  })
]
