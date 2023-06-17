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
  local current_gen previous_gen
  current_gen="$(home-manager generations | head -n1 | cut -d '>' -f 2 | tr -d '[:space:]')"
  previous_gen="$(home-manager generations | tail -n1 | cut -d '>' -f 2 | tr -d '[:space:]')"
  nvd diff "${previous_gen}" "${current_gen}"
}

function nixshell() {
  [[ -z ${1} ]] && return
  BASE_DIR="${SCRIPT_DIR}/nixos/shell-configs"
  declare -a EXTRA_FILES=()
  [[ ! -f "${BASE_DIR}/${1}.nix" ]] && {
    reportWarning "No shell config exists for ${1}"
    return
  }
  EXTRA_FILES+=("default.nix" "shell.nix")
  [[ ${1} == "rust" ]] && EXTRA_FILES+=("rust-toolchain.toml")
  cp -v "${BASE_DIR}/${1}.nix" flake.nix
  for FILE in "${EXTRA_FILES[@]}"; do
    cp "${BASE_DIR}/${FILE}" "${FILE}"
  done
  git add flake.nix "${EXTRA_FILES[@]}"
  nix flake update
  git add flake.lock
  nix develop
}

function nixb() {
  nix flake update --commit-lock-file
}
