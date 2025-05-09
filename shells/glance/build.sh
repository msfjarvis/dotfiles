#!/usr/bin/env bash

EXPR="
let
  pkgs = import <nixpkgs> { };
  settingsFormat = pkgs.formats.yaml { };
  settingsFile = settingsFormat.generate \"glance.yaml\" (import ./${1:?});
in
\"\${settingsFile}\"
"

nix build --option substitute false --impure -I nixpkgs=flake:nixpkgs --expr "${EXPR}"

glance -config ./result
