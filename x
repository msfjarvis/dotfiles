#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e
set -u
set -o pipefail

declare -a SCRIPTS_TO_TEST=()
SCRIPTS_TO_TEST+=("aliases")
SCRIPTS_TO_TEST+=("apps")
SCRIPTS_TO_TEST+=("bash_completions.bash")
SCRIPTS_TO_TEST+=("common")
SCRIPTS_TO_TEST+=("devtools")
SCRIPTS_TO_TEST+=("files")
SCRIPTS_TO_TEST+=("gitshit")
SCRIPTS_TO_TEST+=("install.sh")
SCRIPTS_TO_TEST+=("minecraft")
SCRIPTS_TO_TEST+=("nix")
SCRIPTS_TO_TEST+=("nixos/setup-channels.sh")
SCRIPTS_TO_TEST+=("paste")
SCRIPTS_TO_TEST+=("pre-push-hook")
SCRIPTS_TO_TEST+=("server")
SCRIPTS_TO_TEST+=("setup/00-android_sdk.sh")
SCRIPTS_TO_TEST+=("setup/01-adb_multi.sh")
SCRIPTS_TO_TEST+=("setup/02-android_udev.sh")
SCRIPTS_TO_TEST+=("setup/common.sh")
SCRIPTS_TO_TEST+=("shell-init")
SCRIPTS_TO_TEST+=("system")
SCRIPTS_TO_TEST+=("system_linux")
SCRIPTS_TO_TEST+=("x")

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
