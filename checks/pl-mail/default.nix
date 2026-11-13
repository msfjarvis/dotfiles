{ inputs, pkgs, ... }:
assert import ../../tests/pl-mail.nix { system = inputs.self.nixosConfigurations.melody; };
pkgs.runCommand "pl-mail-module-check" { } "touch $out"
