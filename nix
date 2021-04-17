#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: MIT

function nixpatch() {
  [ -z "${1}" ] && return
  patchelf --set-interpreter "$(nix eval --raw nixpkgs.glibc.outPath)/lib/ld-linux-x86-64.so.2" "${1}"
}
