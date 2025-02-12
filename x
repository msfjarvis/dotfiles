#!/usr/bin/env bash
# shellcheck disable=SC1091

set -euo pipefail

function nom_build() {
  local FLAKE
  FLAKE="${1}"
  nom build --option always-allow-substitutes true .#nixosConfigurations."${FLAKE}".config.system.build.toplevel
}

function cleanup_generations() {
  sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system old
  nix-env --delete-generations --profile ~/.local/state/nix/profiles/home-manager old
  sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
}

ARG="${1:-nothing}"

case "${ARG}" in
chart)
  nom build .#topology.x86_64-linux.config.output
  ;;
darwin-check)
  nom build .#darwinConfigurations.Harshs-MacBook-Pro.system
  ;;
darwin-switch)
  darwin-rebuild switch --option sandbox false --print-build-logs --flake .
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
matara-check)
  nom_build matara
  ;;
matara-switch)
  nh os switch .
  cleanup_generations
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
gradle-hash)
  shift
  VERSION="${1}"
  nix hash to-sri --type sha256 "$(nix-prefetch-url --type sha256 https://services.gradle.org/distributions/gradle-"${VERSION}"-bin.zip)"
  ;;
*)
  echo "Invalid command: ${ARG}"
  exit 1
  ;;
esac
