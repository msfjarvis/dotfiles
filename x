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
SCRIPTS_TO_TEST+=("system_darwin")
SCRIPTS_TO_TEST+=("system_linux")
SCRIPTS_TO_TEST+=("system_wsl")
SCRIPTS_TO_TEST+=("wireguard")
SCRIPTS_TO_TEST+=("x")

NIXPKGS_OLD_REVISION=e33fdbaf5495094df4a6be01279b8bbcf2ee96bf
NIXPKGS_NEW_REVISION=4c020b5ce0d99fa12d448a5e3f79ce7cc512863c

case "${1:-nothing}" in
  autofix)
    shellcheck -f diff "${SCRIPTS_TO_TEST[@]}" | git apply
    ;;
  bump)
    fd -tf \\.nix$ -X sd "$NIXPKGS_OLD_REVISION" "$NIXPKGS_NEW_REVISION"
    git commit -am "nixos: bump custom-nixpkgs"
    ;;
  darwin-switch)
    nix-channel --update
    cp nixos/darwin-configuration.nix ~/.nixpkgs/darwin-configuration.nix
    darwin-rebuild switch --show-trace
    ;;
  fmt | format)
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
    cp nixos/ryzenbox-configuration.nix ~/.config/nixpkgs/home.nix
    home-manager build --show-trace
    ;;
  home-switch)
    nix-channel --update
    cp nixos/ryzenbox-configuration.nix ~/.config/nixpkgs/home.nix
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
    shfmt -d -s -i 2 -ci "${SCRIPTS_TO_TEST[@]}"
    find . -type f -name '*.nix' -exec nixfmt -c {} \;
    shellcheck -x "${SCRIPTS_TO_TEST[@]}"
    ;;
  wsl-switch)
    nix-channel --update
    cp nixos/wsl-configuration.nix ~/.config/nixpkgs/home.nix
    home-manager switch
    ;;
esac
