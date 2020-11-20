#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: GPL-3.0-only

function nixsync() {
  nix-env -q >"${SCRIPT_DIR}"/packages.nix.list
  [ -z "${1}" ] && {
    git -C "${SCRIPT_DIR}" cam "nix: sync"
    git -C "${SCRIPT_DIR}" push
  }
}

function nixpatch() {
  [ -z "${1}" ] && return
  patchelf --set-interpreter "$(nix eval nixpkgs.glibc.outPath | sed 's/"//g')/lib/ld-linux-x86-64.so.2" "${1}"
}

# This madness tries to convert `nix-env -q` output into a list of packages that can be passed to `nix-env -iA`
function listnixpkgs() {
  "${SCRIPT_DIR}"/nixsplit.kts <"${SCRIPT_DIR}"/packages.nix.list | xargs -I {} nix search '^{}$' 2>/dev/null | rg unstable | choose 1
}
