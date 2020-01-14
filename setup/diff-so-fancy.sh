#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

# shellcheck source=setup/common.sh
source "${SCRIPT_DIR:?}"/setup/common.sh
# shellcheck source=gitshit
source "${SCRIPT_DIR}"/gitshit

function check_and_install_dsf() {
  local DFS INSTALLED_VERSION LATEST_VERSION
  DFS="$(command -v diff-so-fancy)"
  echoText "Checking and installing 'diff-so-fancy'"
  if [ -z "${DFS}" ]; then
    install_dsf
  else
    INSTALLED_VERSION="$(diff-so-fancy --version 2>&1 | tail -n1 | cut -d ':' -f 2 | sed 's/ //g')"
    LATEST_VERSION="$(get_latest_release so-fancy/diff-so-fancy | sed 's/v//')"
    if [ "${INSTALLED_VERSION}" != "${LATEST_VERSION}" ]; then
      printUpgradeBanner "diff-so-fancy" "${INSTALLED_VERSION}" "${LATEST_VERSION}"
      install_dsf
    else
      printUpToDateBanner "diff-so-fancy" "${INSTALLED_VERSION}"
    fi
  fi
}

function install_dsf() {
  aria2c 'https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy' --allow-overwrite=true -d /tmp -o diff-so-fancy
  sudo install /tmp/diff-so-fancy /usr/local/bin/diff-so-fancy
  rm -f /tmp/diff-so-fancy 2>/dev/null
}

check_and_install_dsf
