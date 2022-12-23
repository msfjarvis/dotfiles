#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e
set -u
set -o pipefail

case "${1:-nothing}" in
  githook)
    set -x
    ln -sf "$(pwd)"/pre-push-hook .git/hooks/pre-push
    set +x
    ;;
  home-check)
    nix build .#homeConfigurations.x86_64-linux.ryzenbox.activationPackage
    ;;
  home-switch)
    nix build .#homeConfigurations.x86_64-linux.ryzenbox.activationPackage
    source ./result/activate
    ;;
  install)
    ./install.sh
    ;;
  oracle-check)
    nix build .#homeConfigurations.aarch64-linux.server.activationPackage
    ;;
  oracle-switch)
    nix build .#homeConfigurations.aarch64-linux.server.activationPackage
    source ./result/activate
    ;;
  server-check)
    nix build .#homeConfigurations.x86_64-linux.server.activationPackage
    ;;
  server-switch)
    nix build .#homeConfigurations.x86_64-linux.server.activationPackage
    source ./result/activate
    ;;
esac
