{
  pkgs,
  inputs,
  ...
}:
assert import ../../tests/microvm-network.nix {
  system = inputs.self.nixosConfigurations.matara;
  inherit (pkgs) lib;
};
pkgs.runCommand "microvm-network-config-check" { } "touch $out"
