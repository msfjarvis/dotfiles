#!/usr/bin/env bash
# shellcheck disable=SC1091

set -euo pipefail

function nom_build() {
  local FLAKE
  FLAKE="${1}"
  nom build --option always-allow-substitutes true --option max-jobs "$(($(nproc) / 2))" .#nixosConfigurations."${FLAKE}".config.system.build.toplevel
}

function cleanup_generations() {
  sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system old
  nix-env --delete-generations --profile ~/.local/state/nix/profiles/home-manager old
  sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
}

ARG="${1:-nothing}"

case "${ARG}" in
boot)
  nh os boot .
  ;;
chart)
  nom build .#topology.x86_64-linux.config.output
  ;;
check)
  shift
  TARGET="${1:-}"
  [[ -z ${TARGET} ]] && TARGET="${HOSTNAME}"
  nom_build "${TARGET}"
  ;;
darwin-check)
  nom build ".#darwinConfigurations.${HOSTNAME}.system"
  ;;
darwin-switch)
  darwin-rebuild switch --option sandbox false --print-build-logs --flake .
  ;;
gradle-hash)
  shift
  VERSION="${1}"
  NIX_HASH="$(nix hash to-sri --type sha256 "$(nix-prefetch-url --type sha256 https://services.gradle.org/distributions/gradle-"${VERSION}"-bin.zip)")"
  printf '{ version = "%s"; hash = "%s";}' "${VERSION}" "${NIX_HASH}" | nixfmt >modules/nixos/profiles/desktop/gradle-version.nix
  ;;
test)
  nh os test .
  ;;
switch)
  nh os switch .
  cleanup_generations
  ;;
*)
  echo "Invalid command: ${ARG}"
  exit 1
  ;;
esac
