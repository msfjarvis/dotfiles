{
  pkgs,
  inputs,
  ...
}:
assert import ../../tests/forgejo-archives.nix {
  system = inputs.self.nixosConfigurations.wailord;
};
pkgs.runCommand "forgejo-archives-config-check" { } "touch $out"
