#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e
set -u
set -o pipefail

case "${1:-nothing}" in
  githook)
    ln -sf "$(pwd)"/pre-push-hook .git/hooks/pre-push
    ;;
  home-check)
    shift
    home-manager build --flake .#ryzenbox
    ;;
  home-switch)
    shift
    home-manager switch --flake .#ryzenbox
    ;;
  install)
    ./install.sh
    ;;
  oracle-check)
    shift
    home-manager build --flake .#server
    ;;
  oracle-switch)
    shift
    home-manager switch --flake .#server
    ;;
esac
