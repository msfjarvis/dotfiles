#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e
set -u
set -o pipefail

case "${1:-nothing}" in
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
    shift
    home-manager build --print-build-logs --flake .#ryzenbox
    ;;
  home-switch)
    shift
    home-manager switch --print-build-logs --flake .#ryzenbox
    ;;
  install)
    ./install.sh
    ;;
  oracle-check)
    shift
    home-manager build --print-build-logs --flake .#server
    ;;
  oracle-switch)
    shift
    home-manager switch --print-build-logs --flake .#server
    ;;
esac
