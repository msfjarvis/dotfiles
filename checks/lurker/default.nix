{
  pkgs,
  inputs,
  ...
}:
assert import ../../tests/lurker.nix { system = inputs.self.nixosConfigurations.melody; };
pkgs.runCommand "lurker-config-check" { } "touch $out"
