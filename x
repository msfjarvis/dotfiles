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
    nix build .#homeConfigurations.x86_64-linux.ryzenbox.activationPackage "${@}"
    ;;
  home-switch)
    shift
    nix build .#homeConfigurations.x86_64-linux.ryzenbox.activationPackage "${@}"
    source ./result/activate
    ;;
  install)
    ./install.sh
    ;;
  oracle-check)
    shift
    nix build .#homeConfigurations.aarch64-linux.server.activationPackage "${@}"
    ;;
  oracle-switch)
    shift
    nix build .#homeConfigurations.aarch64-linux.server.activationPackage "${@}"
    source ./result/activate
    ;;
  server-check)
    shift
    nix build .#homeConfigurations.x86_64-linux.server.activationPackage "${@}"
    ;;
  server-switch)
    shift
    nix build .#homeConfigurations.x86_64-linux.server.activationPackage "${@}"
    source ./result/activate
    ;;
esac
