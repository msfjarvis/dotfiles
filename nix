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
