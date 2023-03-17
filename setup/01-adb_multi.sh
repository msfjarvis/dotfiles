#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: MIT

# shellcheck source=common
source "${SCRIPT_DIR:?}"/common

function setup_adb_multi() {
  local CLONE_DIR
  CLONE_DIR="/tmp/adb-multi"
  if [ -d "${CLONE_DIR}" ]; then
    git -C "${CLONE_DIR}" pull origin master
  else
    git clone https://github.com/Kreach3r/adb-multi -b master "${CLONE_DIR}"
  fi
  echoText "Setting up adb-multi"
  cp "${SCRIPT_DIR}/configs/adb-multi/config.cfg" "${CLONE_DIR}"/config.cfg
  "${CLONE_DIR}"/adb-multi generate "${HOME}/bin"
  cp "${CLONE_DIR}"/adb-multi ~/bin
  cp "${CLONE_DIR}"/config.cfg ~/bin
}

if [[ ${BASH_SOURCE[0]} == "${0}" ]]; then
  set -euo pipefail
  setup_adb_multi
  set +euo pipefail
fi
