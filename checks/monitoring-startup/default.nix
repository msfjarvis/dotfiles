{
  pkgs,
  inputs,
  ...
}:
assert import ../../tests/monitoring-startup.nix {
  system = inputs.self.nixosConfigurations.matara;
};
pkgs.runCommand "monitoring-startup-config-check" { } "touch $out"
