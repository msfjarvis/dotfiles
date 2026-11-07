#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
palette="$repo_root/modules/nixos/stylix/catppuccin-mocha.yaml"
schemes="$(nix build --no-link --print-out-paths "$repo_root#nixosConfigurations.ryzenbox.pkgs.base16-schemes")"
cp "$schemes/share/themes/catppuccin-mocha.yaml" "$palette"
chmod u+w "$palette"
