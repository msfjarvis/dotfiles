#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e
set -u
set -o pipefail

function nom_build() {
  local FLAKE
  FLAKE="${1}"
  nom build .#nixosConfigurations."${FLAKE}".config.system.build.toplevel
}

function cleanup_generations() {
  sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system old
  nix-env --delete-generations --profile ~/.local/state/nix/profiles/home-manager old
  sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
}

ARG="${1:-nothing}"

case "${ARG}" in
  crusty-check)
    nom_build crusty
    ;;
  crusty-switch)
    nh os switch .
    cleanup_generations
    ;;
  darwin-check)
    nom build .#darwinConfigurations.Harshs-MacBook-Pro.system
    ;;
  darwin-switch)
    darwin-rebuild switch --print-build-logs --flake .
    ;;
  home-boot)
    nh os boot .
    ;;
  home-check)
    nom_build ryzenbox
    ;;
  home-switch)
    nh os switch .
    cleanup_generations
    ;;
  home-test)
    nh os test .
    ;;
  server-boot)
    nh os boot .
    ;;
  server-check)
    nom_build wailord
    ;;
  server-switch)
    nh os switch .
    cleanup_generations
    ;;
  *)
    echo "Invalid command: ${ARG}"
    exit 1
    ;;
esac
