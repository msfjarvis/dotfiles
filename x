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

  local cmd=(nom build --option always-allow-substitutes true)
  if [[ $local_build == "true" ]]; then
    local max_jobs
    max_jobs=$(($(nproc || echo 1) / 2))
    cmd+=(--option max-jobs "$max_jobs" --builders "''")
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
  local version=$1 nix_hash
  nix_hash="$(nix hash to-sri --type sha256 "$(nix-prefetch-url --type sha256 https://services.gradle.org/distributions/gradle-"${version}"-bin.zip)")"
  printf '{ version = "%s"; hash = "%s";}' "${version}" "${nix_hash}" >modules/nixos/profiles/desktop/gradle-version.nix
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
  echo "  switch         Switch the system [--local]"
  echo "  upstream-build  Build with upstream caches only"
  exit 1
}

main() {
  local arg=$1
  shift || true

  case $arg in
  boot)
    run_command sudo nixos-rebuild --print-build-logs boot --flake .
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
    local local_build=false
    while [[ $# -gt 0 ]]; do
      case $1 in
      --local)
        local_build=true
        shift
        ;;
      *)
        shift
        ;;
      esac
    done
    if [[ "$(uname)" == "Darwin" ]]; then
      echo "Error: 'test' command is not supported on Darwin systems" >&2
      exit 1
    fi
    if [[ $local_build == "true" ]]; then
      local max_jobs
      max_jobs=$(($(nproc || echo 1) / 2))
      run_command sudo nixos-rebuild --print-build-logs test --option builders "" --option max-jobs "$max_jobs" --flake .
    else
      run_command sudo nixos-rebuild --print-build-logs test --flake .
    fi
    ;;
  switch)
    local local_build=false
    while [[ $# -gt 0 ]]; do
      case $1 in
      --local)
        local_build=true
        shift
        ;;
      *)
        shift
        ;;
      esac
    done
    if [[ "$(uname)" == "Darwin" ]]; then
      run_command sudo darwin-rebuild switch --option sandbox false --print-build-logs --flake .
    else
      if [[ $local_build == "true" ]]; then
        local max_jobs
        max_jobs=$(($(nproc || echo 1) / 2))
        run_command sudo nixos-rebuild --print-build-logs switch --option builders "" --option max-jobs "$max_jobs" --flake .
      else
        run_command sudo nixos-rebuild --print-build-logs switch --flake .
      fi
      cleanup_generations
    fi
    ;;
  upstream-build)
    if [[ "$(uname)" == "Darwin" ]]; then
      echo "Error: 'upstream-build' command is not supported on Darwin systems" >&2
      exit 1
    fi
    run_command sudo nixos-rebuild switch \
      --option substituters "https://cache.nixos.org https://nix-community.cachix.org" \
      --option trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" \
      --option extra-substituters "" \
      --option extra-trusted-public-keys "" \
      --print-build-logs \
      --flake \
      "$@"
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
