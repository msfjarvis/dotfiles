#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

trap 'rm /tmp/ripgrep.deb 2>/dev/null' INT TERM EXIT

# shellcheck source=setup/common.sh
source "${SCRIPT_DIR:?}"/setup/common.sh
# shellcheck source=gitshit
source "${SCRIPT_DIR}"/gitshit

function check_and_install_ripgrep() {
  local RIPGREP RIPGREP_ARTIFACT INSTALLED_VERSION LATEST_VERSION
  RIPGREP="$(command -v rg)"
  echoText "Checking and installing ripgrep"
  if [ -z "${RIPGREP}" ]; then
    install_ripgrep
  else
    INSTALLED_VERSION="$(rg --version | head -n1 | awk '{print $2}')"
    LATEST_VERSION="$(get_latest_release BurntSushi/ripgrep)"
    if [ "${INSTALLED_VERSION}" != "${LATEST_VERSION}" ]; then
      printUpgradeBanner "ripgrep" "${INSTALLED_VERSION}" "${LATEST_VERSION}"
      install_ripgrep
    else
      printUpToDateBanner "ripgrep" "${INSTALLED_VERSION}"
    fi
  fi
}

function install_ripgrep() {
  local RIPGREP_ARTIFACT
  RIPGREP_ARTIFACT="ripgrep_.*_amd64.deb"
  cd /tmp || return 1
  aria2c "$(get_release_assets BurntSushi/ripgrep | grep "${RIPGREP_ARTIFACT}")" -o ripgrep.deb
  sudo dpkg -i ripgrep.deb
  rm -rf ripgrep.deb 2>/dev/null
  cd "${SCRIPT_DIR}" || return 1
}

check_and_install_ripgrep
