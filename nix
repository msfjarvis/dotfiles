#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: MIT

function nixpatch() {
  [ -z "${1}" ] && return
  patchelf --set-interpreter "$(nix eval --raw nixpkgs.glibc.outPath)/lib/ld-linux-x86-64.so.2" "${1}"
}

function nixdiff() {
  [[ -z ${1} || -z ${2} ]] && return
  diff -Naur <(nix-store -qR /nix/var/nix/profiles/per-user/"$(whoami)"/home-manager-"${1}"-link | sort) <(nix-store -qR /nix/var/nix/profiles/per-user/"$(whoami)"/home-manager-"${2}"-link | sort)
}

function nixshell() {
  [[ -z ${1} ]] && return
  cp -v "${SCRIPT_DIR}/nixos/shell-configs/${1}.nix" shell.nix
}
