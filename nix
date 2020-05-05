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

function nixrstr() {
  [ -f "${SCRIPT_DIR}"/packages.nix.list ] && return
  while read -r pkg; do nix-env -i "${pkg}"; done < <(cat "${SCRIPT_DIR}"/packages.nix.list)
}
