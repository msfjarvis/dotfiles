{
  pkgs,
  inputs,
  ...
}:
assert import ../../tests/remote-chrome.nix { system = inputs.self.nixosConfigurations.matara; };
pkgs.runCommand "remote-chrome-config-check" { } "touch $out"
