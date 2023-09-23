#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e
set -u
set -o pipefail

ARG="${1:-nothing}"

case "${ARG}" in
  crusty-check)
    sudo nixos-rebuild build --flake .#crusty
    ;;
  crusty-switch)
    sudo nixos-rebuild switch --flake .#crusty
    ;;
  darwin-check)
    darwin-rebuild build --print-build-logs --flake .#work-macbook
    ;;
  darwin-switch)
    darwin-rebuild switch --print-build-logs --flake .#work-macbook
    ;;
  githook)
    ln -sf "$(pwd)"/pre-push-hook .git/hooks/pre-push
    ;;
  home-check)
    home-manager build --print-build-logs --impure --flake .#ryzenbox
    ;;
  home-switch)
    home-manager switch --print-build-logs --impure --flake .#ryzenbox
    ;;
  install)
    ./install.sh
    ;;
  server-check)
    sudo nixos-rebuild build --flake .#wailord
    ;;
  server-switch)
    sudo nixos-rebuild switch --flake .#wailord
    ;;
  *)
    echo "Invalid command: ${ARG}"
    exit 1
    ;;
esac
