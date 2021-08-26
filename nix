#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: MIT

function nixpatch() {
  [ -z "${1}" ] && return
  patchelf --set-interpreter "$(nix eval --raw nixpkgs.glibc.outPath)/lib/ld-linux-x86-64.so.2" "${1}"
}

function nixdiff() {
  [[ -z ${1} || -z ${2} ]] && return
  local gen1 gen2
  gen1="/nix/var/nix/profiles/per-user/$(whoami)/home-manager-${1}-link"
  gen2="/nix/var/nix/profiles/per-user/$(whoami)/home-manager-${2}-link"
  if [[ ! -e ${gen1} ]]; then
    echoText "Generation ${1} does not exist"
    return 1
  elif [[ ! -e ${gen2} ]]; then
    echoText "Generation ${2} does not exist"
  fi
  nvd diff "${gen1}" "${gen2}"
}

function nixshell() {
  [[ -z ${1} ]] && return
  cp -v "${SCRIPT_DIR}/nixos/shell-configs/${1}.nix" shell.nix
}
