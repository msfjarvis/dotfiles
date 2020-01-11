#!/usr/bin/env bash

# Copyright (C) Harsh Shandilya <msfjarvis@gmail.com>
# SPDX-License-Identifier: GPL-3.0-only

trap 'rm /tmp/hugo.deb 2>/dev/null' INT TERM EXIT

# shellcheck source=setup/common.sh
source "${SCRIPT_DIR:?}"/setup/common.sh
# shellcheck source=gitshit
source "${SCRIPT_DIR}"/gitshit

function check_and_install_hugo() {
  local HUGO HUGO_ARTIFACT INSTALLED_VERSION LATEST_VERSION
  HUGO="$(command -v hugo)"
  echoText "Checking and installing hugo"
  if [ -z "${HUGO}" ]; then
    install_hugo
  else
    INSTALLED_VERSION="$(hugo version | awk '{print $5}' | cut -d '-' -f 1)"
    LATEST_VERSION="$(get_latest_release gohugoio/hugo)"
    if [ "${INSTALLED_VERSION}" != "${LATEST_VERSION}" ]; then
      printUpgradeBanner "hugo" "${INSTALLED_VERSION}" "${LATEST_VERSION}"
      install_hugo "${LATEST_VERSION}"
    else
      printUpToDateBanner "hugo" "${INSTALLED_VERSION}"
    fi
  fi
}

function install_hugo() {
  local HUGO_ARTIFACT
  HUGO_ARTIFACT="hugo_extended_.*_Linux-64bit.deb"
  cd /tmp || return 1
  aria2c "$(get_release_assets gohugoio/hugo | grep "${HUGO_ARTIFACT}")" -o hugo.deb
  sudo dpkg -i hugo.deb
  rm -rf hugo.deb 2>/dev/null
  cd "${SCRIPT_DIR}" || return 1
}

check_and_install_hugo
