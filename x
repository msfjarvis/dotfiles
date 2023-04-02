#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e
set -u
set -o pipefail

ARG="${1:-nothing}"

case "${ARG}" in
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
    home-manager build --print-build-logs --flake .#ryzenbox
    ;;
  home-switch)
    home-manager switch --print-build-logs --flake .#ryzenbox
    ;;
  install)
    ./install.sh
    ;;
  oracle-check)
    home-manager build --print-build-logs --flake .#server
    ;;
  oracle-switch)
    home-manager switch --print-build-logs --flake .#server
    ;;
  *)
    echo "Invalid command: ${ARG}"
    exit 1
    ;;
esac
