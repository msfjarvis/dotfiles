#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: MIT

function nixpatch() {
  [ -z "${1}" ] && return
  local glibc_path
  glibc_path="$(nix eval --raw nixpkgs#glibc.outPath)"
  comma patchelf --set-interpreter "${glibc_path}/lib/ld-linux-x86-64.so.2" "${1}"
}

function nixdiff() {
  local CUR_GEN OLD_GEN
  case "$(uname)" in
    "Darwin")
      CUR_GEN="$(fd -j1 --max-depth 1 -tl system- /nix/var/nix/profiles/ | tail -n1)"
      OLD_GEN="$(fd -j1 --max-depth 1 -tl system- /nix/var/nix/profiles/ | tail -n2 | head -n1)"
      ;;
    "Linux")
      if [[ -n "$(command -v home-manager)" ]]; then
        CUR_GEN="$(fd -j1 --max-depth 1 -tl home-manager- ~/.local/state/nix/profiles/ | tail -n1)"
        OLD_GEN="$(fd -j1 --max-depth 1 -tl home-manager- ~/.local/state/nix/profiles/ | head -n1)"
      else
        CUR_GEN_NUM="$(nixos-rebuild --fast list-generations | tail -n +2 | awk '{print $1}' | head -n1)"
        OLD_GEN_NUM="$(nixos-rebuild --fast list-generations | tail -n +2 | awk '{print $1}' | head -n2 | tail -n1)"
        CUR_GEN="/nix/var/nix/profiles/system-${CUR_GEN_NUM}-link"
        OLD_GEN="/nix/var/nix/profiles/system-${OLD_GEN_NUM}-link"
      fi
      ;;
  esac
  nvd diff "${OLD_GEN}" "${CUR_GEN}"
}

function nixshell() {
  [[ -z ${1} ]] && return
  BASE_DIR="${SCRIPT_DIR}/shell-configs"
  declare -a FILES_TO_COPY=()
  [[ ! -d "${BASE_DIR}/${1}" ]] && {
    reportWarning "No shell config exists for ${1}"
    return
  }
  FILES_TO_COPY+=("default.nix" "shell.nix" "${1}/flake.nix")
  [[ ${1} == "rust" ]] && FILES_TO_COPY+=("rust-toolchain.toml")
  for FILE in "${FILES_TO_COPY[@]}"; do
    cp "${BASE_DIR}/${FILE}" "$(basename "${FILE}")"
  done
  git add .
  nix flake update
  git add flake.lock
  nix develop
}

function nixb() {
  nix flake update --commit-lock-file
}
