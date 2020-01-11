#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

trap 'rm -rf /tmp/xclip 2>/dev/null' INT TERM EXIT

# shellcheck source=setup/common.sh
source "${SCRIPT_DIR:?}"/setup/common.sh
# shellcheck source=gitshit
source "${SCRIPT_DIR}"/gitshit

function install_xclip() {
  local INSTALLED_VERSION LATEST_VERSION SCRIPT_DIR
  echoText "Checking and installing xclip"
  INSTALLED_VERSION="$(xclip -version 2>&1 | head -n1 | awk '{print $3}')"
  LATEST_VERSION="$(get_latest_release astrand/xclip)"
  if [ "${INSTALLED_VERSION}" != "${LATEST_VERSION}" ]; then
    printUpgradeBanner "xclip" "${INSTALLED_VERSION}" "${LATEST_VERSION}"
    echoText "Building latest xclip version from git"
    cd /tmp || return 1
    git clone https://github.com/astrand/xclip
    cd xclip || return 1
    autoreconf
    ./configure
    make all -j"$(nproc)"
    sudo make install install.man
  else
    printUpToDateBanner "xclip" "${INSTALLED_VERSION}"
  fi
  rm -rf /tmp/xclip 2>/dev/null
}

install_xclip
