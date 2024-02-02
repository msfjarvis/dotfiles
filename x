#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e
set -u
set -o pipefail

ARG="${1:-nothing}"

case "${ARG}" in
  crusty-check)
    nixos-rebuild build --flake .#crusty
    ;;
  crusty-switch)
    sudo nixos-rebuild switch --flake .#crusty
    ;;
  darwin-check)
    darwin-rebuild build --print-build-logs --flake .
    ;;
  darwin-switch)
    darwin-rebuild switch --print-build-logs --flake .
    ;;
  githook)
    ln -sf "$(pwd)"/pre-push-hook .git/hooks/pre-push
    ;;
  home-check)
    nixos-rebuild build --flake .#ryzenbox
    ;;
  home-switch)
    sudo nixos-rebuild switch --flake .#ryzenbox
    sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system old
    nix-env --delete-generations --profile ~/.local/state/nix/profiles/home-manager old
    sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
    ;;
  home-test)
    sudo nixos-rebuild test --flake .#ryzenbox
    ;;
  install)
    ./install.sh
    ;;
  server-check)
    nixos-rebuild build --flake .#wailord
    ;;
  server-switch)
    sudo nixos-rebuild switch --flake .#wailord
    ;;
  *)
    echo "Invalid command: ${ARG}"
    exit 1
    ;;
esac
