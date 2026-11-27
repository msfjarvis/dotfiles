{
  pkgs,
  inputs,
  ...
}:
assert import ../../tests/remote-chrome.nix {
  host = inputs.self.nixosConfigurations.matara;
  guest = inputs.self.nixosConfigurations.chrome-cdp;
};
pkgs.runCommand "remote-chrome-config-check" { } "touch $out"
