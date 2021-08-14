#!/usr/bin/env bash

set -e
set -u
set -o pipefail

declare -a SCRIPTS_TO_TEST=()
SCRIPTS_TO_TEST+=("aliases")
SCRIPTS_TO_TEST+=("apps")
SCRIPTS_TO_TEST+=("bash_completions.bash")
SCRIPTS_TO_TEST+=("common")
SCRIPTS_TO_TEST+=("darwin-init")
SCRIPTS_TO_TEST+=("devtools")
SCRIPTS_TO_TEST+=("files")
SCRIPTS_TO_TEST+=("gitshit")
SCRIPTS_TO_TEST+=("install.sh")
SCRIPTS_TO_TEST+=("nix")
SCRIPTS_TO_TEST+=("paste")
SCRIPTS_TO_TEST+=("setup/00-android_sdk.sh")
SCRIPTS_TO_TEST+=("setup/01-adb_multi.sh")
SCRIPTS_TO_TEST+=("setup/02-android_udev.sh")
SCRIPTS_TO_TEST+=("setup/common.sh")
SCRIPTS_TO_TEST+=("server")
SCRIPTS_TO_TEST+=("shell-init")
SCRIPTS_TO_TEST+=("system")
SCRIPTS_TO_TEST+=("wireguard")
SCRIPTS_TO_TEST+=("x")

case "${1:-nothing}" in
  autofix)
    shellcheck -f diff "${SCRIPTS_TO_TEST[@]}" | git apply
    ;;
  format)
    shfmt -w -s -i 2 -ci "${SCRIPTS_TO_TEST[@]}"
    find . -type f -name '*.nix' -exec nixfmt {} \;
    ;;
  githook)
    set -x
    ln -sf "$(pwd)"/pre-push-hook .git/hooks/pre-push
    set +x
    ;;
  home-check)
    nix-channel --update
    cp nixos/home-manager.nix ~/.config/nixpkgs/home.nix
    home-manager build --show-trace
    ;;
  home-switch)
    nix-channel --update
    cp nixos/home-manager.nix ~/.config/nixpkgs/home.nix
    home-manager switch
    ;;
  install)
    ./install.sh
    ;;
  server-switch)
    nix-channel --update
    cp nixos/server-configuration.nix ~/.config/nixpkgs/home.nix
    home-manager switch
    ;;
  test | nothing)
    ./x format
    for script in "${SCRIPTS_TO_TEST[@]}"; do
      echo "Checking ${script}..."
      shellcheck -x "${script}"
    done
    ;;
esac