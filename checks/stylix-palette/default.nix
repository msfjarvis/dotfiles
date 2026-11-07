{ pkgs, ... }:
pkgs.runCommand "stylix-palette-check" { } ''
  diff -u ${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml ${../../modules/nixos/stylix/catppuccin-mocha.yaml}
  touch "$out"
''
