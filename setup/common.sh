#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <me@msfjarvis.dev>
# SPDX-License-Identifier: GPL-3.0-only

# shellcheck source=common
source "${SCRIPT_DIR}"/common

function printUpgradeBanner() {
  local BIN_NAME CURRENT_VERSION NEW_VERSION
  BIN_NAME="${1}"
  CURRENT_VERSION="${2}"
  NEW_VERSION="${3}"
  reportWarning "Outdated version of ${BIN_NAME:?} found, upgrading (${CURRENT_VERSION:?} -> ${NEW_VERSION:?})"
}

function printUpToDateBanner() {
  local BIN_NAME VERSION
  BIN_NAME="${1}"
  VERSION="${2}"
  reportWarning "${BIN_NAME:?} (${VERSION:?}) is already up to date!"
}

# Empty function to satisfy installer
function setup_common() { echo; }
