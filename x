#!/usr/bin/env bash

set -euo pipefail

# Function to run commands with output capture and error handling
run_command() {
  echo "Running command: $*"
  "$@"
}

get_hostname() {
  hostname
}

nom_build() {
  local flake=$1
  local local_build=${2:-false}
  local max_jobs=$(($(nproc || echo 1) / 2))

  local cmd=(nom build --option always-allow-substitutes true --option max-jobs "$max_jobs")
  if [[ $local_build == "true" ]]; then
    cmd+=(--builders "''")
  fi
  cmd+=(".#nixosConfigurations.$flake.config.system.build.toplevel")

  run_command "${cmd[@]}"
}

cleanup_generations() {
  run_command sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system old
  run_command nix-env --delete-generations --profile ~/.local/state/nix/profiles/home-manager old
  run_command sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
}

gradle_hash() {
  local version=$1
  run_command nix-prefetch-url --type sha256 "https://services.gradle.org/distributions/gradle-$version-bin.zip"
}

usage() {
  echo "Usage: x <command> [options]"
  echo
  echo "Commands:"
  echo "  boot            Boot the system"
  echo "  chart           Build the topology chart"
  echo "  check [target]  Check a Nix flake"
  echo "  gradle-hash     Calculate Gradle hash"
  echo "  test           Run tests"
  echo "  switch         Switch the system"
  exit 1
}

main() {
  local arg=$1
  shift || true

  case $arg in
  boot)
    run_command nh os boot .
    ;;
  chart)
    run_command nix build '.#topology.x86_64-linux.config.output'
    ;;
  check)
    local target local_build=false
    while [[ $# -gt 0 ]]; do
      case $1 in
      --local)
        local_build=true
        shift
        ;;
      *)
        target=$1
        shift
        ;;
      esac
    done
    target=${target:-$(get_hostname)}
    if [[ "$(uname)" == "Darwin" ]]; then
      run_command nom build ".#darwinConfigurations.$target.system"
    else
      nom_build "$target" "$local_build"
    fi
    ;;

  gradle-hash)
    if [[ $# -lt 1 ]]; then
      echo "Error: Gradle version required"
      exit 1
    fi
    gradle_hash "$1"
    ;;
  test)
    run_command nh os test .
    ;;
  switch)
    if [[ "$(uname)" == "Darwin" ]]; then
      run_command sudo darwin-rebuild switch --option sandbox false --print-build-logs --flake .
    else
      run_command nh os switch .
      cleanup_generations
    fi
    ;;
  --help | -h)
    usage
    ;;
  *)
    if [[ -z ${cmd:-} ]]; then
      usage
    else
      echo "Invalid command: $cmd"
      exit 1
    fi
    ;;
  esac
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  if [[ $# -eq 0 ]]; then
    usage
  else
    main "$@"
  fi
fi
